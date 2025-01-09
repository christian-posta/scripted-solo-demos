"""
This is a sample FastAPI application that demonstrates how to use the Guardrails API.

To run this server in debug mode, naviagate to the parent directory of this file and run:
  
  ```bash
  python3 -m fastapi dev --host 0.0.0.0 ./app.py
  ```

This command will also reload theprogram as you make changes to the source code.
"""

import os
import signal
import json
from typing import Annotated
from fastapi import FastAPI, Header, Request
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine, EngineResult
from presidio_anonymizer.entities import RecognizerResult
from openai.types.chat.chat_completion import ChatCompletion
import api
import uvicorn
import logging


app = FastAPI()
# Set up the engine, loads the NLP module (spaCy model by default) and other PII recognizers
analyzer = AnalyzerEngine()
anon = AnonymizerEngine()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@app.post("/request", response_model=api.GuardrailsPromptResponse)
async def create_item(
    req: api.GuardrailsPromptRequest,
    x_action: Annotated[str | None, Header()] = None,
) -> api.GuardrailsPromptResponse:

    logger.info(f"New request: {req.body}")
    jsn = json.loads(req.body)

    replace = next((msg.get("content", "") for msg in jsn.get("messages", []) if msg.get("role") != "system"), "")
    logger.info(f"About to analyze: {replace}")

    results = analyzer.analyze(text=replace, language="en")
    # The results returned here are a list of RecognizerResult objects, each containing information about detected PII, including entity type, start and end positions, and confidence score.
    # Log the RecognizerResult information
    for result in results:
        logger.info(f"Detected PII: {result.entity_type}, Score: {result.score}, Location: {result.start}-{result.end}")

    above_threshold = any(i.score > 0.7 for i in results)
    if not above_threshold:
        return api.GuardrailsPromptResponse(
            action=api.PassAction(reason="No reason"),
        )

    match x_action:
        case "block":
            logger.info("PII detected in the request, going to reject")
            return api.GuardrailsPromptResponse(
                action=api.RejectAction(
                    body="PII detected in the request",
                    status_code=403,
                    reason="PII detected",
                ),
            )
        case "mask":
            logger.info("PII detected in the request, going to mask")
            # Call analyzer to get results
            anonymized: EngineResult = anon.anonymize(
                text=replace,
                analyzer_results=[
                    RecognizerResult(
                        entity_type=i.entity_type,
                        start=i.start,
                        end=i.end,
                        score=i.score,
                    )
                    for i in results
                    if i.score > 0.7
                ],
            )
           
            user_message = next((msg for msg in jsn["messages"] if msg.get("role") == "user"), None)
            if user_message:
                user_message["content"] = anonymized.text

            logger.info("Checking what the updated messages will be after masking" + json.dumps(jsn["messages"]))

            return api.GuardrailsPromptResponse(
                action=api.MaskAction(
                    body=json.dumps(jsn),
                    reason="PII detected and masked",
                ),
            )
        case _:
            return api.GuardrailsPromptResponse(
                action=api.PassAction(reason="No reason"),
            )


@app.post("/response", response_model=api.GuardrailsResponseResponse)
async def get_items(
    request: Request,
    req: api.GuardrailsResponseRequest,
) -> api.GuardrailsResponseResponse:

    logger.info(f"About to analyze response: {req.body}")
    cc = ChatCompletion.model_validate_json(req.body)

    # TODO: need to decide which message to handle since the first one
    # could be a system message
    replace = cc.choices[0].message.content or ""
    results = analyzer.analyze(replace or "", language="en")
    print(results)
    above_threshold = any(i.score > 0.7 for i in results)
    print(above_threshold)
    if not above_threshold:
        return api.GuardrailsResponseResponse(
            action=api.PassAction(reason="No PII detected"),
        )
    # Call analyzer to get results
    anonymized: EngineResult = anon.anonymize(
        text=replace,
        analyzer_results=[
            RecognizerResult(
                entity_type=i.entity_type,
                start=i.start,
                end=i.end,
                score=i.score,
            )
            for i in results
        ],
    )
    cc.choices[0].message.content = anonymized.text
    return api.GuardrailsResponseResponse(
        action=api.MaskAction(
            body=json.dumps(cc.model_dump()),
            reason="PII detected and masked",
        ),
    )


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/shutdown")
async def shutdown():
    os.kill(os.getpid(), signal.SIGTERM)


def main():
    uvicorn.run(app, host="0.0.0.0", port=8000)
