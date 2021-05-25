## Gloo Mesh global routing, multi-cluster, multi-region with Gloo Edge and ArgoCD

Salient notes for this demo:

Global URLs:
http://argocd.mesh.ceposta.solo.io
http://gogs.mesh.ceposta.solo.io
http://dashboard.mesh.ceposta.solo.io

Global service hostnames
http://web-api.mesh.ceposta.solo.io
^^ this is routable from outside the mesh as well as within the mesh with GM VirtualDestination

DNS is set to regional affinity; if you curl http://web-api.mesh.ceposta.solo.io from west coast, you'll be routed to west cluster, if you curl from Europe, you should be routed to east cluster.

Note, the config namespace is `demo-config` in the Gloo Mesh Management plane