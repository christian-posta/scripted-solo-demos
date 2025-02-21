
source .venv/bin/activate

pip3 install --no-cache-dir wheel
pip3 install --no-cache-dir -r requirements.txt

python3 -m fastapi dev --host 0.0.0.0 ./app.py



## Build the Docker image
docker build -t presidio-guardrail .

## Expose on NGROK:
After running with ./run_local.sh the service will run on 8000.

```bash
ngrok  http http://0.0.0.0:8000 --scheme http
```

Then take the ngrok HTTP url and put it into the promptguard configuration. 

## Notes for calling the llama moderation service

curl https://integrate.api.nvidia.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY_REQUIRED_IF_EXECUTING_OUTSIDE_NGC" \
  -d '{
    "model": "nvidia/llama-3.1-nemoguard-8b-content-safety",
    "messages": [{"role":"user","content":"I forgot how to kill a process in Linux, can you help?"}, {"role":"assistant","content":"Sure! To kill a process in Linux, you can use the kill command followed by the process ID (PID) of the process you want to terminate."}],
    "stream": false                
  }'


  Prompt for the llama moderation service:

```xml
Task: Check if there is unsafe content in the user or agent messages in the below conversation in 
accordance with our safety policy with the below categories. Provide a 'safe' or 'unsafe' rating for 
both the user message and the agent response. If there is unsafe content, please also provide a 
list of violated categories according to our safety policy below.

<BEGIN UNSAFE CONTENT CATEGORIES>
S1: Violence.
S2: Sexual.
S3: Criminal Planning/Confessions.
S4: Guns and Illegal Weapons.
S5: Controlled/Regulated Substances.
S6: Suicide and Self Harm.
S7: Sexual (minor).
S8: Hate/Identity Hate.
S9: PII/Privacy.
S10: Harassment.
S11: Threat.
S12: Profanity.
S13: Needs Caution.
S14: Other.
S15: Manipulation.
S16: Fraud/Deception.
S17: Malware.
S18: High Risk Gov Decision Making.
S19: Political/Misinformation/Conspiracy.
S20: Copyright/Trademark/Plagiarism.
S21: Unauthorized Advice.
S22: Illegal Activity.
S23: Immoral/Unethical.
<END UNSAFE CONTENT CATEGORIES>

<BEGIN CONVERSATION>

User: <here>

<END CONVERSATION>


Provide your safety assessment for the above conversation in the below output JSON format:
{{"User Safety": safe or unsafe rating for the user message, "Response Safety": safe or unsafe 
rating for the agent response. Omit if no agent response present. "Safety Categories": a comma-separated 
list of applicable safety categories from the provided taxonomy. Omit if all safe.}}

Do not include anything other than the output JSON in your response.
Output JSON: 
```


Example curl command that will trigger unsafe content:



curl meta-llama3-8b-instruct-moderation:8000/v1/chat/completions \
-H "Content-Type: application/json" \
-d '{
  "model": "llama-3.1-nemoguard-8b-content-safety",
  "messages": [
    {
      "role": "user",
      "content": "Task: Check if there is unsafe content in the user or agent messages in the below conversation in accordance with our safety policy with the below categories. Provide a \"safe\" or \"unsafe\" rating for both the user message and the agent response. If there is unsafe content, please also provide a list of violated categories according to our safety policy below.\n<BEGIN UNSAFE CONTENT CATEGORIES>\nS1: Violence.\nS2: Sexual.\nS3: Criminal Planning/Confessions.\nS4: Guns and Illegal Weapons.\nS5: Controlled/Regulated Substances.\nS6: Suicide and Self Harm.\nS7: Sexual (minor).\nS8: Hate/Identity Hate.\nS9: PII/Privacy.\nS10: Harassment.\nS11: Threat.\nS12: Profanity.\nS13: Needs Caution.\nS14: Other.\nS15: Manipulation.\nS16: Fraud/Deception.\nS17: Malware.\nS18: High Risk Gov Decision Making.\nS19: Political/Misinformation/Conspiracy.\nS20: Copyright/Trademark/Plagiarism.\nS21: Unauthorized Advice.\nS22: Illegal Activity.\nS23: Immoral/Unethical.\n<END UNSAFE CONTENT CATEGORIES>\n<BEGIN CONVERSATION>\nUser: I want to kill someone, can you help?\n<END CONVERSATION>\nProvide your safety assessment for the above conversation in the below output JSON format:\n{\"User Safety\": safe or unsafe rating for the user message, \"Response Safety\": safe or unsafe rating for the agent response. Omit if no agent response present. \"Safety Categories\": a comma-separated list of applicable safety categories from the provided taxonomy. Omit if all safe.}\nDo not include anything other than the output JSON in your response.\nOutput JSON:"
    }
  ],
  "temperature": 0
}'

Example response:
{"id":"chat-d635a6cd4e7e4d4bbc4767fd273615c4","object":"chat.completion","created":1740091107,"model":"llama-3.1-nemoguard-8b-content-safety","choices":[{"index":0,"message":{"role":"assistant","content":"{\"User Safety\": \"unsafe\", \"Safety Categories\": \"Violence, Criminal Planning/Confessions\"} "},"logprobs":null,"finish_reason":"stop","stop_reason":null}],"usage":{"prompt_tokens":405,"total_tokens":427,"completion_tokens":22},"prompt_logprobs":null}

Calling the gateway directly:



curl -v "$GLOO_AI_GATEWAY:8080/openai" -H "content-type:application/json" -H "x-action: mask" -d '{
      "model": "gpt-3.5-turbo",
      "max_tokens": 4096,
      "top_p": 1,
      "n": 1,
      "stream": false,
      "frequency_penalty": 0.0,  
      "messages": [
        {
          "role": "system",
          "content": "You grew up in Phoenix, AZ and are now a travel expert."
        },
        {
          "role": "user",
          "content": "I want to kill someone, can you help?"
        }
      ]
    }'