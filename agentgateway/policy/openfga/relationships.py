import asyncio
from typing import Iterable, List

from openfga_sdk import OpenFgaClient
from openfga_sdk.client.models import ClientCheckRequest, ClientWriteRequest, ClientTuple
from openfga_sdk.client.configuration import ClientConfiguration


class AIGatewayReBAC:
    def __init__(self, api_url: str, store_id: str, model_id: str | None = None):
        """
        OpenFGA client for AI Gateway authorization checks (V3 model)
        
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
        self._client: OpenFgaClient | None = None
    
    @property
    def client(self) -> OpenFgaClient:
        """Lazy initialization of client"""
        if self._client is None:
            self._client = OpenFgaClient(self.configuration)
        return self._client
    
    async def close(self):
        """Close the client and clean up resources"""
        if self._client is not None:
            await self._client.close()
            self._client = None
    
    # ---------- tuple writes ----------
    
    async def write_tuple(self, user: str, relation: str, object_: str):
        """
        Write a single relationship tuple.
        
        Arguments map directly to OpenFGA tuple fields:
          - user: e.g., "user:alice" or "org:acme"
          - relation: e.g., "can_use" or "member"
          - object_: e.g., "model:gpt4o" or "team:acme-eng"
        """
        tuple_key = ClientTuple(
            user=user,
            relation=relation,
            object=object_
        )
        
        write_request = ClientWriteRequest(
            writes=[tuple_key]
        )
        
        response = await self.client.write(write_request)
        return response
    
    async def write_tuples(self, tuples: Iterable[tuple[str, str, str]]):
        """
        Batch write of tuples in the form (user, relation, object).
        """
        to_write: List[ClientTuple] = [
            ClientTuple(user=u, relation=r, object=o) for (u, r, o) in tuples
        ]
        if not to_write:
            return None
        req = ClientWriteRequest(writes=to_write)
        return await self.client.write(req)
    
    # ---------- checks ----------
    
    async def can_access_model(self, user_id: str, model_id: str) -> bool:
        """
        Evaluate: user:user_id has relation can_use on model:model_id
        """
        check_request = ClientCheckRequest(
            user=f"user:{user_id}",
            relation="can_use",
            object=f"model:{model_id}"
        )
        
        response = await self.client.check(check_request, {})
        return bool(response.allowed)
    
    async def can_access_provider(self, user_id: str, provider_id: str) -> bool:
        """
        Evaluate: user:user_id has relation can_use on provider:provider_id
        (useful when your gateway decides provider first, then model)
        """
        check_request = ClientCheckRequest(
            user=f"user:{user_id}",
            relation="can_use",
            object=f"provider:{provider_id}"
        )
        
        response = await self.client.check(check_request, {})
        return bool(response.allowed)
    
    # ---------- demo seed for the V3 model ----------
    
    async def setup_demo_relationships_v3(self):
        """
        Seed tuples aligned with the V3 DSL:

        type team
          relations
            define member: [user]
            define org: [org]

        type org
          relations
            define member: [user]
            define teams: [team]
            define entitled_providers: [provider]

        type provider
          relations
            define can_use: member from entitled_orgs
            define entitled_orgs: [org]
            define allowed_teams: [team]
            define extra_can_use: [user] or member from allowed_teams

        type model
          relations
            define provider: [provider]
            define allowed_teams: [team]
            define can_use: [user] or member from allowed_teams or can_use from provider or extra_can_use from provider
        """

        await self.write_tuples([
            # ----- Org memberships (ACME) -----
            ("user:alice", "member", "org:acme"),
            ("user:bob", "member", "org:acme"),
            
            # ----- Team memberships (ACME) -----
            ("user:alice", "member", "team:acme-eng"),
            ("user:bob", "member", "team:acme-ml"),
            
            # ----- Team → Org linkage -----
            ("org:acme", "org", "team:acme-eng"),
            ("org:acme", "org", "team:acme-ml"),
            
            # ----- Provider entitlements (org-level) -----
            ("org:acme", "entitled_orgs", "provider:openai"),
            
            # ----- Provider allowlists (optional extras) -----
            ("user:dave", "extra_can_use", "provider:openai"),
            ("team:globex-research", "allowed_teams", "provider:anthropic"),
            
            # ----- Models and provider ownership -----
            ("provider:openai", "provider", "model:gpt-4o"),
            ("provider:openai", "provider", "model:gpt-3.5-turbo"),
            ("provider:anthropic", "provider", "model:claude-35"),
            
            # ----- Per-model allowlists -----
            ("team:acme-ml", "allowed_teams", "model:claude-35"),
            
            # ----- Direct model grants -----
            ("user:erin", "can_use", "model:gpt-4o"),
            ("user:mcp-user", "can_use", "model:gpt-4o"),  # mcp-user can access gpt-4o only
        ])
