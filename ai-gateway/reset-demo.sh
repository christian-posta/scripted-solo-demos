
delete_00(){
    kubectl delete -f resources/00-basic-passthrough/
}

delete_01(){
    kubectl delete -f resources/01-call-llm/
}

delete_02(){
    kubectl rollout restart deployment redis -n gloo-system
    kubectl delete -f resources/02-secure-llm-jwt/
}

delete_03(){
    kubectl delete -f resources/03-ratelimit-token-usage/
}

delete_04(){
    kubectl delete -f resources/extensions/model-failover.yaml
    kubectl delete -f resources/04-model-failover/
}

delete_05(){
    kubectl delete -f resources/05-prompt-guard/
    kubectl delete -f resources/extensions/promptguard.yaml
}
delete_06(){
    kubectl delete -f resources/extensions/redis.yaml
    kubectl delete -f resources/06-semantic-cache/
}

delete_07(){
    kubectl delete -f resources/07-rag/
    kubectl delete -f resources/extensions/vector-db.yaml
}

delete_08(){
    kubectl delete -f resources/08-provider-traffic-shift/
}


delete_all(){
    delete_02
    delete_03
    delete_04
    delete_05
    delete_06
    delete_07
    #instead of deleting the 08 resources, we'll just overwrite   
    # the openai httproute

}

reset_all(){
    delete_all
    kubectl apply -f resources/01-call-llm/
}


reset_for_00() {
    reset_all
    delete_00
}

reset_for_01() {
    delete_all
    delete_00
    delete_01
}

reset_for_02() {
    reset_all
}

reset_for_03() {
    reset_all
    kubectl rollout restart deployment redis -n gloo-system
    kubectl apply -f resources/02-secure-llm-jwt/
}

reset_for_04() {
    reset_all
    kubectl apply -f resources/extensions/model-failover.yaml
}

reset_for_05() {
    reset_all
    # kubectl apply -f resources/extensions/promptguard.yaml
}

reset_for_06() {
    reset_all
    kubectl apply -f resources/extensions/redis.yaml
}

reset_for_07() {
    reset_all
    kubectl apply -f resources/extensions/vector-db.yaml
}

reset_for_08() {
    reset_all
    kubectl apply -f resources/extensions/ollama.yaml
    kubectl apply -f resources/08-provider-traffic-shift/qwen-upstream.yaml
    
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --for)
            shift
            case $1 in
                all) delete_all ;;  # New option for deleting all resources
                0) reset_for_00 ;;
                1) reset_for_01 ;;
                2) reset_for_02 ;;
                3) reset_for_03 ;;
                4) reset_for_04 ;;
                5) reset_for_05 ;;  
                6) reset_for_06 ;;
                7) reset_for_07 ;;
                8) reset_for_08 ;;
                *) echo "Invalid option for --reset-for. Use all, 0, 1, 2, 3, 4, 5, 6, 7, or 8." ;;
            esac
            exit 0
            ;;
        *) echo "Unknown parameter passed: $1" ;;
    esac
    shift
done





