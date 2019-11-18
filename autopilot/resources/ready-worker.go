package ready

import (
	"context"
	"sort"

	"k8s.io/apimachinery/pkg/labels"

	"github.com/go-logr/logr"
	"github.com/solo-io/autopilot/pkg/ezkube"
	appsv1 "k8s.io/api/apps/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	v1 "autorouter.example.io/pkg/apis/autoroutes/v1"
)

type Worker struct {
	Client ezkube.Client
	Logger logr.Logger
}

func (w *Worker) Sync(ctx context.Context, route *v1.AutoRoute, inputs Inputs) (v1.AutoRoutePhase, *v1.AutoRouteStatusInfo, error) {

	// check if we need resync
	needsResync, err := w.needsResync(route, inputs.Deployments.Items)
	if err != nil {
		// errors can be returned; the worker will be retried (with backoff)
		return "", nil, err
	}

	if needsResync {
		// if we need resync, return to the resync phase so that worker can
		// restore us to Ready
		return v1.AutoRoutePhaseSyncing, nil, nil
	} else {
		// otherwise continue in Ready phase
		// worker will be called at work interval
		return v1.AutoRoutePhaseReady, nil, nil
	}
}

func (w *Worker) needsResync(route *v1.AutoRoute, deployments []appsv1.Deployment) (bool, error) {
	expectedDeployments := route.Status.SyncedDeployments
	actualDeployments, err := w.getMatchingDeployments(route, deployments)
	if err != nil {
		return false, err
	}
	sort.Strings(expectedDeployments)
	sort.Strings(actualDeployments)

	// if the expected routes exist, do nothing (resync on interval)
	return !stringSlicesEqual(expectedDeployments, actualDeployments), nil
}

func stringSlicesEqual(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i, v := range a {
		if v != b[i] {
			return false
		}
	}
	return true
}

func (w *Worker) getMatchingDeployments(route *v1.AutoRoute, deployments []appsv1.Deployment) ([]string, error) {
	// get the selector from the autoRoute
	// we'll use this to match the deployments from our inputs
	selector, err := metav1.LabelSelectorAsSelector(&route.Spec.DeploymentSelector)
	if err != nil {
		return nil, err
	}

	w.Logger.Info("cycle through each deployment and check that the labels match our selector")
	var matchingDeployments []string
	for _, deployment := range deployments {
		labelsToMatch := labels.Set(deployment.Labels)
		if deployment.Namespace == route.Namespace && selector.Matches(labelsToMatch) {
			w.Logger.Info("found matching deployment", "deployment", deployment.Name)
			matchingDeployments = append(matchingDeployments, deployment.Name)
		}
	}

	return matchingDeployments, nil
}
