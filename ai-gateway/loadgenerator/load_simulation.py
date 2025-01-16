import asyncio
import random
import time
import aiohttp
from datetime import datetime

import os

USER1="eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpc3MiOiJzb2xvLmlvIiwib3JnIjoic29sby5pbyIsIm5hbWUiOiJKb2huIERvZSIsInN1YiI6Impkb2UxIiwidGVhbSI6ImNzciIsImxsbXMiOnsib2xsYW1hIjpbInF3ZW4tMC41YiJdfX0.ptkENx2Q8yIaX9-BobGhe7OaHde3PjN_Rv-EITy83fZjrIRclkk5AL4GlmX_UcK6iGewEV5MiSRBkpNcFrWJYQE-8Dg92609jtxbBBmt6Zx10y_tw5NqKpfbhZrtT7S_FufDAdAh4QVWqGrvC6WOKRrDAOj4uGAMwv6YKf0kBLkP56J3aBsqkZ-ZSb4eVqfoYH9RBr-X7JBgyIg4MVQyxpmEv-0tzlKNDisIChPb5bkMJcGzYRModwbx87IV_mXaac5cmUa_sRLneAXNyRuXxRG-4Jvm31HMH_uCsiPxkgsRAi7_8LHOGcWMI5WrOH_FsRcRzIHaQBUt4NchcqxDUA"
USER2="eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpc3MiOiJzb2xvLmlvIiwib3JnIjoic29sby5pbyIsIm5hbWUiOiJKb2hubnkgRG9lIiwic3ViIjoiamRvZTIiLCJ0ZWFtIjoiZW5nIiwibGxtcyI6eyJvbGxhbWEiOlsicXdlbi0wLjViIl19fQ.DDsC1K7C65xhBkwS6kwFB7KtVAKusnSdt51fNAQtllIZidcIphBmhPn97BQYgBEaag4s85x7k2q-JkDn89sLq3gq-K0Xao1Z0lwUZCxXg4QRkcsgpUK7awe7roKC9NSU3azodJwCafF9EvLjuFARBOrThNic9FGS14j0iRPJ5E9RbcxSasOavdsfnlxaMeVy9RDjkJ2MTE2Gb5ddLpdNHoKlhrPlGjogf4KH-g5jNaFmrwuPsFNwoYjLqpCZW0Uw-b_j5dJr6JbOgAkNfswE7ZzD-uJMxbxX9r4epnv83-5Br8wEP5ztLaHN_zwuH_k_jJbOycSM_wTSXS1L8GfRlQ"
USER3="eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpc3MiOiJzb2xvLmlvIiwib3JnIjoic29sby5pbyIsIm5hbWUiOiJKb2huYXRoYW4gRG9lIiwic3ViIjoiamRvZTMiLCJ0ZWFtIjoicmV0dXJucyIsImxsbXMiOnsib2xsYW1hIjpbInF3ZW4tMC41YiJdfX0.U80mOvXJ-8cqfvJSveYG-1uExTzir4Im_vTgfTE0mtIsYCVbg-Hkq3_pOLfOrCRZKnGKG1fpzwG3UGDaBkdK2SJOsV5JUgAmv7A61H0WIJEV5ihGPbiuyxXTnm64MGyegEECRIFYiQSS8Nvyt0z9qcYoiufBRQqX_mxucKSQvdDQHDwaXDuR8c3mjeEz1epM0RWltXrWC2fRJcS4BjXS10lM8QWS5FYOjKwTguxnVeC2X6srTwVIhYDfzD5mKph_qRHAaBPejE01wA7RTW1b-0TGVwNjTAZFE7dgvAozuerS9z09k29dJkOMpK4RDqsB6erdgjnOVSVTs6depSot1w"

TOKENS = [
    USER1,
    USER2,
    USER3
]

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--url', type=str, default="gloo-proxy-ai-gateway.gloo-system.svc.cluster.local:8080", help='The URL of the gateway endpoint')
args = parser.parse_args()

ENDPOINT = f"http://{args.url}/load"
STATS_SLEEP_SECONDS = 15

# Sample messages to randomly choose from
MESSAGES = [
    "How are you today?",
    "What's the weather like?", 
    "Tell me an interesting fact.",
    "I'm learning about AI.",
    "Can you help me with a question?",
    "What's your favorite topic?",
    "Let's have a friendly chat.",
    "Tell me about yourself.",
    "I'd love to learn something new.",
    "How does AI work?"
]

class Stats:
    def __init__(self):
        self.successes = 0
        self.failures = 0
        self.start_time = time.time()

stats = Stats()

async def send_requests(session, token, user_id):
    headers = {
        "Authorization": f"Bearer {token}",
        "Host": "load-generator.gloo.solo.io"
    }
    
    while True:
        try:
            message = random.choice(MESSAGES)
            payload = {
                "model": "qwen:0.5b",
                "messages": [
                    {
                        "role": "user",
                        "content": message
                    }
                ]
            }
            #print(f"Sending request to {ENDPOINT} with headers: {headers} and payload: {payload}")
            async with session.post(ENDPOINT, json=payload, headers=headers) as response:
                response_body = await response.json()  # Log the response body
                response_headers = response.headers  # Log the response headers
                
                #print(f"Response status: {response.status}, headers: {response_headers}, body: {response_body}")
                
                if 200 <= response.status < 300:
                    stats.successes += 1
                else:
                    stats.failures += 1
                    
        except Exception as e:
            print(f"Exception occurred: {e}")  # Log the exception
            stats.failures += 1
            
        await asyncio.sleep(random.uniform(3, 25))

async def print_stats():
    while True:
        elapsed = int(time.time() - stats.start_time)
        print(f"Elapsed time: {elapsed}s | Successes: {stats.successes} | Failures: {stats.failures}")
        await asyncio.sleep(STATS_SLEEP_SECONDS)

async def main():
    async with aiohttp.ClientSession() as session:
        tasks = []
        for user_id, token in enumerate(TOKENS):
            tasks.append(send_requests(session, token, user_id))
        tasks.append(print_stats())
        
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())