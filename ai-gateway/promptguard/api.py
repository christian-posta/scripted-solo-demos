from pydantic import BaseModel


### Guardrails API ###
# The following classes are used to define the request and response models for the Guardrails API.


class GuardrailsPromptRequest(BaseModel):
    """
    GuardrailsPromptRequest is the request model for the Guardrails prompt API.
    """

    """
    body is the JSON string that contains the request body.
    """
    body: str


class MaskAction(BaseModel):
    """
    MaskAction is the response model for the Mask action.
    """

    """
    body is the JSON string that contains the response body.
    """
    body: str

    """
    reason is a human readable string that explains the reason for the action.
    """
    reason: str | None


class RejectAction(BaseModel):
    """
    RejectAction is the response model for the Reject action.
    """

    """
    body is the JSON string that contains the response body.
    """
    body: str

    """
    status_code is the HTTP status code to be returned in the
    response.
    """
    status_code: int

    """
    reason is a human readable string that explains the reason for the action.
    """
    reason: str | None


class PassAction(BaseModel):
    """
    PassAction is the response model for the Pass action.
    """

    """
    reason is a human readable string that explains the reason for the action.
    """
    reason: str | None


class GuardrailsPromptResponse(BaseModel):
    """
    GuardrailsPromptResponse is the response model for the Guardrails prompt API.
    """

    """
    action is the action to be taken based on the request.
    The following actions are available on the response: 
    - PassAction: No action is required.
    - MaskAction: Mask the response body.
    - RejectAction: Reject the request.
    """
    action: PassAction | MaskAction | RejectAction


class GuardrailsResponseRequest(BaseModel):
    """
    GuardrailsResponseRequest is the request model for the Guardrails response API.
    """

    """
    body is the JSON string that contains the response body.
    """
    body: str


class GuardrailsResponseResponse(BaseModel):
    """
    GuardrailsResponseResponse is the response model for the Guardrails response API.
    """

    """
    action is the action to be taken based on the request.
    The following actions are available on the response: 
    - PassAction: No action is required.
    - MaskAction: Mask the response body.
    """
    action: PassAction | MaskAction
