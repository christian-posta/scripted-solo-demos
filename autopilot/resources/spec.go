package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// AutoRouteSpec defines the desired state of AutoRoute
// +k8s:openapi-gen=true
type AutoRouteSpec struct {
	// Users will provide us with a LabelSelector that tells us which deployments to select
	DeploymentSelector metav1.LabelSelector `json:"deploymentSelector"`
}

// AutoRouteStatusInfo defines an observed condition of AutoRoute
// +k8s:openapi-gen=true
type AutoRouteStatusInfo struct {
	// The Operator will record all the deployments that have routes.
	// If this falls out of sync with the set of routes, the operator will resync
	SyncedDeployments []string `json:"syncedDeployments"`
}
