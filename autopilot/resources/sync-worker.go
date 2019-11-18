package syncing

import (
	"context"

	"autorouter.example.io/pkg/parameters"
	v1alpha3spec "istio.io/api/networking/v1alpha3"
	"istio.io/client-go/pkg/apis/networking/v1alpha3"
	corev1 "k8s.io/api/core/v1"

	"github.com/go-logr/logr"
	"github.com/solo-io/autopilot/pkg/ezkube"

	v1 "autorouter.example.io/pkg/apis/autoroutes/v1"
	appsv1 "k8s.io/api/apps/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/labels"
)

// The Syncing worker will resync the existing services, gateways, and virtual services to ensure that a route
// is exposed on the Istio ingress gateway
type Worker struct {
	Client ezkube.Client
	Logger logr.Logger
}

func (w *Worker) Sync(ctx context.Context, route *v1.AutoRoute, inputs Inputs) (Outputs, v1.AutoRoutePhase, *v1.AutoRouteStatusInfo, error) {
	// get all matching deployments
	inputDeployments, err := w.getMatchingDeployments(route, inputs.Deployments.Items)
	if err != nil {
		return Outputs{}, "", nil, err
	}

	// construct a k8s service and istio vservice for each deployment
	kubeServices, virtualServices, err := w.makeOutputKubeServices(route, inputDeployments)
	if err != nil {
		return Outputs{}, "", nil, err
	}

	// construct one gateway for the vservices
	// will match on hostname <*.route name>
	desiredGateway := v1alpha3.Gateway{
		ObjectMeta: metav1.ObjectMeta{
			Name:      route.Name,
			Namespace: route.Namespace,
		},
		// attach to use the istioingressgateawy (default)
		Spec: v1alpha3spec.Gateway{
			Selector: map[string]string{"istio": "ingressgateway"},

			Servers: []*v1alpha3spec.Server{{
				Port: &v1alpha3spec.Port{
					Number:   80,
					Name:     "http",
					Protocol: "HTTP",
				},
				Hosts: []string{"*." + route.Name},
			}},
		},
	}

	// construct some status info for the operation we performed
	status := &v1.AutoRouteStatusInfo{
		SyncedDeployments: deploymentNames(inputDeployments),
	}

	w.Logger.WithValues(
		"status", status,
		"gateway", desiredGateway.Name,
		"virtual services", len(virtualServices),
		"kube services", len(kubeServices),
	).Info("ensuring the gateway, services and virtual service outputs are created")

	// construct the set of outputs we will return
	outputs := Outputs{
		Services: parameters.Services{
			Items: kubeServices,
		},
		VirtualServices: parameters.VirtualServices{
			Items: virtualServices,
		},
		Gateways: parameters.Gateways{
			Items: []v1alpha3.Gateway{
				desiredGateway,
			},
		},
	}

	return outputs, v1.AutoRoutePhaseReady, status, nil
}

func deploymentNames(deployments []appsv1.Deployment) []string {
	var names []string
	for _, deployment := range deployments {
		names = append(names, deployment.Name)
	}
	return names
}

func (w *Worker) getMatchingDeployments(route *v1.AutoRoute, deployments []appsv1.Deployment) ([]appsv1.Deployment, error) {
	// get the selector from the autoRoute
	// we'll use this to match the deployments from our inputs
	selector, err := metav1.LabelSelectorAsSelector(&route.Spec.DeploymentSelector)
	if err != nil {
		return deployments, err
	}

	w.Logger.Info("cycle through each deployment and check that the labels match our selector")
	var matchingDeployments []appsv1.Deployment
	for _, deployment := range deployments {
		labelsToMatch := labels.Set(deployment.Labels)
		if deployment.Namespace == route.Namespace && selector.Matches(labelsToMatch) {
			w.Logger.Info("found matching deployment", "deployment", deployment.Name)
			matchingDeployments = append(matchingDeployments, deployment)
		}
	}

	return matchingDeployments, nil
}

func (w *Worker) makeOutputKubeServices(route *v1.AutoRoute, deployments []appsv1.Deployment) ([]corev1.Service, []v1alpha3.VirtualService, error) {
	var desiredKubeServices []corev1.Service
	var desiredVirtualServices []v1alpha3.VirtualService

	for _, deployment := range deployments {
		logger := w.Logger.WithValues("deployment", deployment)

		hostname := deployment.Name + "." + route.Name
		logger.Info("adding hostname", "hostname", hostname)

		logger.Info("get the target port from the Deployment's first ContainerPort")
		var targetPort int32
	getFirstPort:
		for _, container := range deployment.Spec.Template.Spec.Containers {
			for _, port := range container.Ports {
				targetPort = port.ContainerPort
				break getFirstPort
			}
		}

		if targetPort == 0 {
			logger.Info("no ports to route to")
			continue
		}

		deploymentSelector := deployment.Spec.Selector

		w.Logger.Info("create a service for the deployment")
		desiredKubeServices = append(desiredKubeServices, corev1.Service{
			ObjectMeta: metav1.ObjectMeta{
				Name:      deployment.Name,
				Namespace: route.Namespace,
			},
			Spec: corev1.ServiceSpec{
				Ports: []corev1.ServicePort{{
					Name: "http",
					Port: targetPort,
				}},
				Selector: deploymentSelector.MatchLabels,
			},
		})

		logger.Info("attach to the gateway we will create for the AutoRoute")
		logger.Info("create a simple route to the service created for the deployment")
		desiredVirtualServices = append(desiredVirtualServices, v1alpha3.VirtualService{
			ObjectMeta: metav1.ObjectMeta{
				Name:      hostname,
				Namespace: route.Namespace,
			},
			Spec: v1alpha3spec.VirtualService{
				Hosts:    []string{hostname},
				Gateways: []string{route.Name},
				Http: []*v1alpha3spec.HTTPRoute{{
					Match: []*v1alpha3spec.HTTPMatchRequest{{
						Uri: &v1alpha3spec.StringMatch{
							MatchType: &v1alpha3spec.StringMatch_Prefix{
								Prefix: "/",
							},
						},
					}},
					Route: []*v1alpha3spec.HTTPRouteDestination{{
						Destination: &v1alpha3spec.Destination{
							Port: &v1alpha3spec.PortSelector{
								Number: uint32(targetPort),
							},
							Host: deployment.Name,
						},
					}},
				}},
			},
		})
	}

	return desiredKubeServices, desiredVirtualServices, nil
}
