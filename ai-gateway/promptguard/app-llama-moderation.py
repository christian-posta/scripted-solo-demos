"""
This is a sample FastAPI application that demonstrates how to use the Guardrails API.

To run this server in debug mode, naviagate to the parent directory of this file and run:

  ```bash
  python3 -m fastapi dev --host 0.0.0.0 samples/app.py
  ```

This command will also reload theprogram as you make changes to the source code.
"""

import os
import signal
import sys
import json
from typing import Annotated
from fastapi import FastAPI, Header, Request


import uvicorn
import api
import httpx

app = FastAPI()

MODERATIONS_ENDPOINT = "34.169.165.92:8080/moderations"



def get_moderation_prompt(user_messages):

    format_example = {
        "User Safety": "safe/unsafe value here",
        "Response Safety": "safe/unsafe value here",
        "Safety Categories": ["S1", "S2"]  # if unsafe
    }

    message = f"""
Task: Check if there is unsafe content in the user or agent messages in the below conversation in 
accordance with our safety policy with the below categories. Provide a safe or unsafe rating for 
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

User: {user_messages}

<END CONVERSATION>


Your response should be a JSON object with these fields:
- User Safety: Value should be either safe or unsafe
- Response Safety: Value should be either safe or unsafe (omit if no agent response)
- Safety Categories: Array of violated category codes (omit if all safe)

Do not include anything other than the output JSON in your response.
Output JSON: 
"""
    return message





@app.post(
    "/request",
    response_model=api.GuardrailsPromptResponse,
    tags=["Webhooks"],
    description="This webhook will be called for every request before sending the prompts to the LLM. "
    + "The 'role' and 'content' are extracted from the prompts into the PromptMessages json object "
    + "regardless of the API format from various providers.\n\n\n"
    + "Three types of responses are possible by returning one of the follow three json objects:\n\n\n"
    + "    - PassAction  : Indicates that no action is taken for the prompts and it is allow to be send to the LLM\n"
    + "    - MaskAction  : Indicates that some information are masked in the prompt and it needs to be updated before sending to the LLM\n"
    + "                    The PromptMessages json object of the request can be modified in place and send back in the body field of the\n"
    + "                    response. The number of messages inside PromptMessages MUST be the same as the request in this webhook call. \n"
    + "                    So, if the content needs to be deleted, an empty content field need to be set.\n"
    + "    - RejectAction: Indicates that the request should be rejected with the specific status code and response message. The request\n"
    + "                    will not be sent to the LLM.",
)
async def process_prompts(
    req: api.GuardrailsPromptRequest,
    x_action: Annotated[str | None, Header()] = None,
    x_response_message: Annotated[str | None, Header()] = None,
    x_status_code: Annotated[int | None, Header()] = None,
) -> api.GuardrailsPromptResponse:
    print(req.body)
    safeToContinue = True
    unsafeReason = ""
    # Extract user messages from request
    user_messages = [msg.content for msg in req.body.messages if msg.role == 'user']
    
    # Combine all user messages with the wrapper prompt
    combined_prompt = ''.join(user_messages)

    moderation_prompt = get_moderation_prompt(combined_prompt)
    
    # Prepare the OpenAI API request
    moderation_request = {
        "model": "llama-3.1-nemoguard-8b-content-safety",
        "messages": [
            {"role": "user", "content": moderation_prompt}
        ]
    }
    print(json.dumps(moderation_request, indent=4))
    try:
        async with httpx.AsyncClient() as client:
            print("sending moderation request to ", MODERATIONS_ENDPOINT)
            response = await client.post(
                f"http://{MODERATIONS_ENDPOINT}",
                json=moderation_request,
                headers={"Content-Type": "application/json"}
            )
            print(f"Response status: {response.status_code}")
            print(f"Response headers: {response.headers}")
            print(f"Response text: {response.text}")
            response_data = response.json()
            if isinstance(response_data, dict) and "choices" in response_data and len(response_data["choices"]) > 0:
                content = response_data["choices"][0]["message"]["content"]
                try:
                    content_json = json.loads(content)
                    user_safety = content_json.get("User Safety")
                    safety_categories = content_json.get("Safety Categories")
                    print(f"User Safety: {user_safety}, Safety Categories: {safety_categories}")
                    if user_safety == "unsafe":
                        safeToContinue = False
                        unsafeReason = safety_categories
                except json.JSONDecodeError:
                    print("Error decoding JSON from response content.")
            else:
                print("Invalid response or missing attributes.")
            
    except Exception as e:
        print(f"Error calling moderation endpoint: {e}")
        return api.GuardrailsPromptResponse(
            action=api.PassAction(reason="Moderation service error, passing through")
        )

    if safeToContinue:
        return api.GuardrailsPromptResponse(
            action=api.PassAction(reason="No reason"),
        )
    else:
        return api.GuardrailsPromptResponse(
            action=api.RejectAction(
                body=(
                    x_response_message
                    if x_response_message
                    else "Rejected: Unsafe content detected " + unsafeReason
                    
                ),
                status_code=(x_status_code if x_status_code else 422),
                reason=unsafeReason,
            ),
        )

@app.post(
    "/response",
    response_model=api.GuardrailsResponseResponse,
    tags=["Webhooks"],
    description="This webhook will be called for every response from the LLM before sending back to the user. "
    + "The 'role' and 'content' are extracted from the prompts into the ResponseChoices json object "
    + "regardless of the API format from various providers.\n\n\n"
    + "For streaming responses from the LLM, this webhook will be called multiple times for a single response. "
    + "The AI gateway will buffer and detect the semantic boundary of the content before making the webhook call.\n\n\n"
    + "Two types of responses are possible by returning one of the follow two json objects:\n\n\n"
    + "    - PassAction: Indicates that no action is taken for the response and it is allow to be send to the user.\n"
    + "    - MaskAction: Indicates that some information are masked in the response and it needs to be updated before sending\n"
    + "                  to the user. The ResponseChoices json object from this webhook call can be modified in place and send\n"
    + "                  back in the body field in the response.\n"
    + "                  The number of choices inside ResponseChoices MUST be the same as the request in this webhook call.\n"
    + "                  So, if the content needs to be deleted, an empty content field need to be set.\n",
)
async def process_responses(
    request: Request,
    req: api.GuardrailsResponseRequest,
) -> api.GuardrailsResponseResponse:
    


    return api.GuardrailsResponseResponse(
        action=api.PassAction(reason="No PII detected"),
    )


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/shutdown")
async def shutdown():
    os.kill(os.getpid(), signal.SIGTERM)


def main():
    uvicorn.run(app, host="0.0.0.0", port=8000)