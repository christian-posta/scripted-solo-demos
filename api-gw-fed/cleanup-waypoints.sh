
kubectl label service purchase-history -n purchase-history istio.io/use-waypoint-
kubectl delete -f resources/waypoints/purchase-history-httproute-jwt.yaml
kubectl delete -f resources/waypoints/purchase-history-waypoint.yaml


kubectl label service web-api -n web-api istio.io/use-waypoint-
kubectl delete -f resources/waypoints/web-api-httproute.yaml
kubectl delete -f resources/waypoints/web-api-waypoint.yaml