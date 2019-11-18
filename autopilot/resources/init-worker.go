package initializing

import (
	"context"

	"github.com/go-logr/logr"
	"github.com/solo-io/autopilot/pkg/ezkube"

	v1 "autorouter.example.io/pkg/apis/autoroutes/v1"
)

// The initializing worker's job is simply to set the phase to "Syncing"
// This tells the user that processing has started
type Worker struct {
	Client ezkube.Client
	Logger logr.Logger
}

func (w *Worker) Sync(ctx context.Context, autoRoute *v1.AutoRoute) (v1.AutoRoutePhase, *v1.AutoRouteStatusInfo, error) {
	// advance to the Syncing state to let the user know the auto route has been processed
	return v1.AutoRoutePhaseSyncing, nil, nil
}
