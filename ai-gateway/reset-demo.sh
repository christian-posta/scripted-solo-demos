
delete_00(){
    kubectl delete -f resources/00-basic-passthrough/
}

delete_01(){
    kubectl delete -f resources/01-call-llm/
}

delete_02(){
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
    kubectl delete -f resources/extensions/ollama/ollama-ns.yaml
    kubectl delete -f resources/extensions/ollama/ollama-deploy.yaml
}


delete_all(){
    delete_00
    delete_01
    delete_02
    delete_03
    delete_04
    delete_05
    delete_06
    delete_07
    delete_08
}


reset_for_00() {
    delete_00
}

reset_for_01() {
    delete_00
    delete_01
}

reset_for_02() {
    delete_00
    delete_02
    # apply 01
    kubectl apply -f resources/01-call-llm/
}

reset_for_03() {
    delete_00
    delete_03
    kubectl apply -f resources/01-call-llm/
    kubectl apply -f resources/02-secure-llm-jwt/
}

reset_for_04() {
    delete_00
    delete_02
    delete_03
    delete_04
    kubectl apply -f resources/01-call-llm/
    kubectl apply -f resources/extensions/model-failover.yaml
}

reset_for_05() {
    delete_00
    delete_02
    delete_03
    delete_04
    delete_05
    kubectl apply -f resources/01-call-llm/
}

reset_for_06() {
    delete_00
    delete_02
    delete_03
    delete_04
    delete_05
    delete_06
    kubectl apply -f resources/01-call-llm/
    kubectl apply -f resources/extensions/redis.yaml
}

reset_for_07() {
    delete_00
    delete_02
    delete_03
    delete_04
    delete_05
    delete_06
    delete_07
    kubectl apply -f resources/01-call-llm/
    kubectl apply -f resources/extensions/vector-db.yaml
}

reset_for_08() {
    delete_00
    delete_02
    delete_03
    delete_04
    delete_05
    delete_06
    delete_07
    delete_08
    kubectl apply -f resources/01-call-llm/
    kubectl apply -f resources/extensions/ollama/ollama-ns.yaml
    kubectl apply -f resources/extensions/ollama/ollama-deploy.yaml
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





