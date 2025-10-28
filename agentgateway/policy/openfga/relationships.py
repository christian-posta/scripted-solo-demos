import json
import os
import asyncio
from openfga_sdk import OpenFgaClient
from openfga_sdk.client.models import ClientCheckRequest, ClientWriteRequest, ClientTuple
from openfga_sdk.client.configuration import ClientConfiguration


class AIGatewayReBAC:
    def __init__(self, api_url, store_id, model_id=None):
        """
        Initialize OpenFGA client
        
        Args:
            api_url: OpenFGA server URL (e.g., http://localhost:8181)
            store_id: OpenFGA store ID
            model_id: Authorization model ID (optional, can be set later)
        """
        self.api_url = api_url
        self.store_id = store_id
        self.model_id = model_id
        self.configuration = ClientConfiguration(
            api_url=api_url,
            store_id=store_id,
            authorization_model_id=model_id
        )
        
        # Create client in async context (lazy initialization)
        self._client = None
    
    @property
    def client(self):
        """Lazy initialization of client"""
        if self._client is None:
            self._client = OpenFgaClient(self.configuration)
        return self._client
    
    async def close(self):
        """Close the client and clean up resources"""
        if self._client is not None:
            await self._client.close()
            self._client = None
    
    async def write_tuple(self, user, relation, object):
        """Write a relationship tuple to OpenFGA"""
        tuple_key = ClientTuple(
            user=user,
            relation=relation,
            object=object
        )
        
        write_request = ClientWriteRequest(
            writes=[tuple_key]
        )
        
        response = await self.client.write(write_request)
        return response
    
    async def can_access_model(self, user_id, model_id):
        """Check if a user can access a model"""
        check_request = ClientCheckRequest(
            user=f"user:{user_id}",
            relation="can_use",
            object=f"model:{model_id}"
        )
        
        response = await self.client.check(check_request, {})
        return response.allowed
    
    async def setup_demo_relationships(self):
        """Set up demo relationships for testing"""
        
        # Set up users as members of teams
        await self.write_tuple("user:alice", "member", "team:research_team")
        await self.write_tuple("user:bob", "member", "team:dev_team")
        
        # Users can directly use certain models
        await self.write_tuple("user:alice", "can_use", "model:claude-3-opus")
        await self.write_tuple("user:alice", "can_use", "model:gpt-4")
        await self.write_tuple("user:bob", "can_use", "model:gpt-4")
        
        # Teams can use certain models (members inherit access)
        # Note: Use team:research_team#member to reference all members of the team
        await self.write_tuple("team:research_team#member", "can_use", "model:claude-3-opus")
        await self.write_tuple("team:dev_team#member", "can_use", "model:gemini-pro")
