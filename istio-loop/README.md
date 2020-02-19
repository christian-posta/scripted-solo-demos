Istio instal:

istioctl manifest generate --set profile=minimal --set autoInjection.enabled=true --set trafficManagement.components.pilot.k8s.hpaSpec.maxReplica1 --set security.enabled=true



for Istio 1.2

~/dev/istio/istio-1.2.10/bin/istioctl kube-inject --injectConfigFile resources/custom-injection/inject-config-1.2.yaml --meshConfigFile resources/custom-injection/mesh-config-1.2.yaml --valuesFile resources/custom-injection/inject-values-1.2.yaml --filename resources/calc.yaml 

