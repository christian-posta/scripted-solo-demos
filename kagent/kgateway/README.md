## Running this demo

To run this demo, you should have kagent already set up.

Run the following to set up this gateway:

```bash
./setup-kgateway
```

From here, you can verify you can reach the gateway with the following:

```bash
./call-gateway.sh
```

You should see an output similar to this:

```json
{                                                                                                                             
  "id": "chatcmpl-BXFeT8ciYv9t1n6BftpoePPM0wZrV",                                                                             
  "object": "chat.completion",                                                                                                
  "created": 1747264689,                                                                                                      
  "model": "gpt-4.1-mini-2025-04-14",                                                                                         
  "choices": [                                                                                                                
    {                                                                                                                         
      "index": 0,                                                                                                             
      "message": {                                                                                                            
        "role": "assistant",                                                                                                  
        "content": "In realms where code and logic play,  \nA concept dwells to save the day—  \nRecursion, like a mirror’s gl
ance,  \nRepeats itself in endless dance.  \n\nA function calls itself anew,  \nTo break a task in parts most true.  \nSolve t
he whole by solving one,  \nUntil the base case says, “Well done!”  \n\nLike nesting dolls within a stack,  \nEach layer waits
, then gives it back.  \nFrom smallest step, the answers rise,  \nBuilding truths before your eyes.  \n\nFactorials, trees, an
d mazes deep,  \nIn recursive folds, their secrets keep.  \nThough tricky seeming at the start,  \nIt’s just a loop with mindf
ul heart.  \n\nSo when you code and face your plight,  \nThink of recursion’s gentle light—  \nA path that winds and bends wit
h grace,  \nTo solve the puzzle piece by piece, embrace.",                                                                    
        "refusal": null,                                                                                                      
        "annotations": []     
      },                                                       
      "logprobs": null,                                                                                                       
      "finish_reason": "stop"                                  
    }                                                          
  ],                                                                                                                          
  "usage": {
    "prompt_tokens": 39,    
    "completion_tokens": 183,                                  
    "total_tokens": 222,                                                                                                      
    "prompt_tokens_details": {
      "cached_tokens": 0,
      "audio_tokens": 0                                                                                                       
    },      
    "completion_tokens_details": {                             
      "reasoning_tokens": 0,                                   
      "audio_tokens": 0,
      "accepted_prediction_tokens": 0,                         
      "rejected_prediction_tokens": 0                          
    }                       
  },                        
  "service_tier": "default",                                   
  "system_fingerprint": "fp_38647f5e19"                        
} 
```

Refer to these docs:
* https://kgateway.dev/docs/quickstart/
* https://kgateway.dev/docs/ai/setup/
* https://kgateway.dev/docs/ai/auth/


## Demo with Kagent

You should create a new OpenAI model that doesn't need an API key that points to:

```text
http://ai-gateway.kgateway-system.svc.cluster.local:8080/openai
```

If you want to add it via CRD:

```bash
kubectl apply -f kgateway/modelconfig.yaml
```

Next, you'll need to create a new agent with the new model. Can do it through the UI, or can do with CRD:

```bash
kubectl apply -f kgateway/agent.yaml
```

Now the agent should communicate though the kgateway. You can now apply policy such as prompt guard:

The "mask" prompt guard works best for the demo:

```bash
kubectl apply -f kgateway/promptguard-mask.yaml
```

Now go to the agent and prompt it with:

```text
What type of number is 5105105105105100?
```

In the response, any time it refers to that number it should <MASK> it.


## Clean up

Clean up is manual at this point. 

You should delete the model configs associated with the kgateway.

Delete the traffic policy for kgateway:

```bash
kubectl delete -f kgateway/prompt-mask.yaml
kubectl delete -f kgateway/agent.yaml
kubectl delete -f kgateway/modelconfig.yaml
```

You can uninstall all of the kgateway with the following:

```bash
helm uninstall -n kgateway-system kgateway-crds
helm uninstall -n kgateway-system kgateway
kubectl delete ns kgateway-system
```