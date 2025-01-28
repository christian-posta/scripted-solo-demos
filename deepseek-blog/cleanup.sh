kubectl delete httproute -n gloo-system deepseek
kubectl delete upstream -n gloo-system deepseek deepseek-local
kubectl delete routeoption -n gloo-system deepseek-prompt-guard
kubectl delete routeoption -n gloo-system deepseek-jwt-opts deepseek-failover-opts deepseek-timeout-opts deepseek-prompt-guard-opts
kubectl delete virtualhostoption -n gloo-system jwt-provider
