import asyncio
import random
import time
import aiohttp
from datetime import datetime

import os

USER1="eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpc3MiOiJzb2xvLmlvIiwib3JnIjoic29sby5pbyIsIm5hbWUiOiJKb2huIERvZSIsInN1YiI6Impkb2UxIiwidGVhbSI6InJldHVybnMiLCJsbG1zIjp7Im9sbGFtYSI6WyJxd2VuLTAuNWIiXX19.SGepFax_pebgIxP1ilT_AynOu5Y-kgg7AI5iR8iGR3HhfYYFBhs9tH9BAZyVgXLS99ZEZrIR5bhwj7TbNqF09TQOeUsL06ersMtJldHibSSH6lJAj-Orr9RsacmCmt1jHpKRk2O_7k0iAXinfnezFQJ3-dMjW23lM83S7P3Ub8jDghoe1wIQPGQh5OBVQYlSRqXrawjH-P15X2NsEo7cG1wuv74LBVMXixsMivvHJU_T5u200F0-LVX7qmHKuC6fc1bZogIe9AZAFB0TrgtzA7Q3dP1a2KrVoCIcG7jwu_a0xcDNXoaQSG4BxBm_017VYS_cfkmQXzwLrNenBAwX7w"
USER2="eyJhbGciOiJSUzI1NiIsInR5cGUiOiJKV1QifQ.eyJpc3MiOiJzb2xvLmlvIiwib3JnIjoic29sby5pbyIsIm5hbWUiOiJKb2hubnkgRG9lIiwic3ViIjoiamRvZTIiLCJ0ZWFtIjoicmV0dXJucyIsImxsbXMiOnsib2xsYW1hIjpbInF3ZW4tMC41YiJdfX0.FkN6UJIwTa9lexZz6DG5FHMJ5tdtXdMORQpaTGUyW55fOt6jTYn5BGEV0MMzflXj9HHMCxumyQXEY2FAF0tanJ71TfIuviCvwtCeue3UPwCaoJhaLZcMr5zZyuMwp4StQ18ovwQly2OOSvrV13NmOa4M-6VIBFSnjGte1WSl5OGcmMjH4GUn1TINRWXIy_CmaL74mv2qL3azhnMuZwxvGEfVENCoei2Q66ePVWgVXA0D1LZohCSHye11D7PWprEbdMgzAA8XHP0FM2SctLWhwKzQwWIv3CSvCcWLXOCsv__5ru81_xvqhDYqrdA-CZEx4jcby5QaQ-rzrHLlvImNNg"
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
            
        await asyncio.sleep(random.uniform(3, 10))

async def print_stats():
    while True:
        elapsed = int(time.time() - stats.start_time)
        print(f"Elapsed time: {elapsed}s | Successes: {stats.successes} | Failures: {stats.failures}")
        await asyncio.sleep(30)

async def main():
    async with aiohttp.ClientSession() as session:
        tasks = []
        for user_id, token in enumerate(TOKENS):
            tasks.append(send_requests(session, token, user_id))
        tasks.append(print_stats())
        
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())