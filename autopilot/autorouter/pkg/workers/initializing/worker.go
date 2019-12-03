package initializing

import (
	"context"

	"github.com/go-logr/logr"
	"github.com/solo-io/autopilot/pkg/ezkube"

	v1 "autorouter.example.io/pkg/apis/autoroutes/v1"
)

// EDIT THIS FILE!  THIS IS SCAFFOLDING FOR YOU TO OWN!

type Worker struct {
	Client ezkube.Client
	Logger logr.Logger
}

func (w *Worker) Sync(ctx context.Context, autoRoute *v1.AutoRoute) (v1.AutoRoutePhase, *v1.AutoRouteStatusInfo, error) {
	panic("implement me!")
}
