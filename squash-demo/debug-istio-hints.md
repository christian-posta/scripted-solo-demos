## Debugging Istio with Squash

First, make sure you have the squash VS code extension installed. Optionally, you can configure the extension to point to a specific version of squash that you have running locally if you want. In the same config dialog box, you'll want to set up the correct remote path for Istio's code. You need to do this because Istio was built (on a CI machine) on a location different than where you'll have the code checked out. We need to give this hint to the debugger. Set the remote path to:

```
/workspace/go/src/istio.io/istio/
```

Now, git clone the Istio source code and checkout to the version you have installed (for example, my demo used 1.0.6). 

Once you have the code checked out and switched to the correct branch of Istio that you've got deployed, open VS code for that project/dir and set a breakpoint on the following line of code:

```
Creating on: $ISTIO_SRC_ROOT/pilot/pkg/config/kube/crd/controller.go (/workspace/go/src/istio.io/istio/pilot/pkg/config/kube/crd/controller.go) :270
```

Now start up the debugger through the IDE, connecting to the `discvoery` container in the pilot pod. 

Now you need to do something in Istio to trigger the line of code to hit. You can deploy a new workload with the sidecar injected (or do automatically with the auto-injection).

To get auto-injection working, make sure you've got it enabled on your Istio install and then label your namespace like the following:

`kubectl label namespace default istio-injection=enabled`


Now when you deploy an application to that `default` namespace, Istio should do the auto-injection and you should see the debugger hit.

For the full demo, see this video:

[https://www.youtube.com/watch?v=qHDKm_ioAnE](https://www.youtube.com/watch?v=qHDKm_ioAnE)
