import grpc
import asyncio
from concurrent import futures
import logging
import json
from google.protobuf.json_format import MessageToDict

# Import the generated ext_authz proto code
from envoy.service.auth.v3 import external_auth_pb2 as pb
from envoy.service.auth.v3 import external_auth_pb2_grpc as pb_grpc

from openfga_client import OpenFgaClient, ClientConfiguration
from openfga_client.credential import Credentials

class AuthorizationService:
    def __init__(self, api_host, api_token, store_id):
        # Initialize OpenFGA client
        self.client = OpenFgaClient(
            ClientConfiguration(
                api_host=api_host,
                store_id=store_id,
                credentials=Credentials(api_token=api_token)
            )
        )
        
        # Model metadata for budget calculations (could be stored in OpenFGA or a separate DB)
        self.model_costs = {
            "claude-3-opus": 0.015,
            "gpt-4": 0.02,
            "gemini-pro": 0.01
        }
        
        self.project_budgets = {
            "nlp_research": 500.00,
            "marketing_campaign": 1000.00
        }
    
    async def check_authorization(self, request):
        """Process an ext_authz request and make authorization decision"""
        try:
            # Extract user, model and request details from the request
            headers = MessageToDict(request.attributes.request.http.headers)
            
            # Extract user ID from authorization header or JWT
            # This is an example - adapt based on your auth method
            user_id = self._extract_user_id(headers)
            if not user_id:
                return self._deny_response("No valid user identification found")
            
            # Parse request path to extract model ID
            # Assuming request path format: /api/models/{model_id}/completions
            path = request.attributes.request.http.path
            model_id = self._extract_model_id(path)
            if not model_id:
                return self._deny_response("Invalid model request path")
            
            # Parse request body to get token count
            # This depends on your API structure
            body = request.attributes.request.http.body
            token_count = self._extract_token_count(body) or 1000  # Default if not specified
            
            # Check if user can access the model
            can_access = await self.client.check({
                "user": f"user:{user_id}",
                "relation": "can_use",
                "object": f"model:{model_id}"
            })
            
            if not can_access.allowed:
                return self._deny_response("Access denied to this model")
            
            # Check if within budget (simplified - real implementation would track usage)
            # In production, you would need a database to track usage
            can_afford = await self._check_budget(user_id, model_id, token_count)
            if not can_afford:
                return self._deny_response("Insufficient budget for this request")
            
            # If authorized, allow the request
            return self._allow_response(user_id, model_id)
            
        except Exception as e:
            logging.error(f"Authorization error: {str(e)}")
            return self._deny_response(f"Authorization error: {str(e)}")
    
    async def _check_budget(self, user_id, model_id, token_count):
        """Check if the request is within budget constraints"""
        # This is simplified - in production, integrate with a usage tracking system
        try:
            # Get projects where user is owner or contributor
            list_objects_response = await self.client.list_objects({
                "user": f"user:{user_id}",
                "relation": "owner",
                "type": "project"
            })
            owner_projects = list_objects_response.objects
            
            list_objects_response = await self.client.list_objects({
                "user": f"user:{user_id}",
                "relation": "contributor",
                "type": "project"
            })
            contributor_projects = list_objects_response.objects
            
            # Check if any project allows the model and has enough budget
            all_projects = owner_projects + contributor_projects
            for project in all_projects:
                project_id = project.split(':')[1]
                
                # Check if model is allowed on this project
                model_allowed = await self.client.check({
                    "user": f"model:{model_id}",
                    "relation": "allowed_model",
                    "object": f"project:{project_id}"
                })
                
                if model_allowed.allowed:
                    # Check budget
                    cost = self.model_costs.get(model_id, 0) * token_count
                    if self.project_budgets.get(project_id, 0) >= cost:
                        # In production: Record this usage against the project budget
                        # self._record_usage(project_id, model_id, token_count, cost)
                        return True
            
            return False
        except Exception as e:
            logging.error(f"Budget check error: {str(e)}")
            return False
    
    def _extract_user_id(self, headers):
        """Extract user ID from request headers"""
        # This is an example - adapt to your authentication method
        auth_header = headers.get("Authorization", "")
        
        if auth_header.startswith("Bearer "):
            # In production, validate and decode the JWT
            # For demo, we'll extract a user ID from a simple token
            token = auth_header[7:]  # Remove "Bearer " prefix
            # This is oversimplified - use a proper JWT library in production
            return token.split('.')[0]  # Just a demo extraction
            
        return None
    
    def _extract_model_id(self, path):
        """Extract model ID from request path"""
        # Assuming path format: /api/models/{model_id}/completions
        # Adapt this based on your actual API structure
        parts = path.strip('/').split('/')
        if len(parts) >= 3 and parts[0] == "api" and parts[1] == "models":
            return parts[2]
        return None
    
    def _extract_token_count(self, body):
        """Extract token count from request body"""
        try:
            # Parse the request body as JSON
            body_dict = json.loads(body)
            return body_dict.get("token_count", 1000)
        except:
            return 1000  # Default value if parsing fails
    
    def _allow_response(self, user_id, model_id):
        """Create an allow response with additional headers"""
        # You can add custom headers that will be sent back to the client
        headers = [
            pb.HeaderValueOption(
                header=pb.HeaderValue(key="x-user-id", value=user_id),
                append=False
            ),
            pb.HeaderValueOption(
                header=pb.HeaderValue(key="x-authorized-model", value=model_id),
                append=False
            )
        ]
        
        return pb.CheckResponse(
            status=pb.OkHttpResponse(headers=headers),
            ok_response=pb.OkHttpResponse(headers=headers)
        )
    
    def _deny_response(self, message):
        """Create a deny response"""
        return pb.CheckResponse(
            status=grpc.StatusCode.PERMISSION_DENIED.value,
            denied_response=pb.DeniedHttpResponse(
                status=pb.HttpStatus(code=403),
                body=message
            )
        )


class AuthorizationServicer(pb_grpc.AuthorizationServiceServicer):
    """gRPC servicer that implements the ext_authz interface"""
    
    def __init__(self, auth_service):
        self.auth_service = auth_service
    
    async def Check(self, request, context):
        """Handle authorization check requests"""
        return await self.auth_service.check_authorization(request)


async def serve(host, port, auth_service):
    """Run the gRPC server"""
    server = grpc.aio.server(futures.ThreadPoolExecutor(max_workers=10))
    pb_grpc.add_AuthorizationServiceServicer_to_server(
        AuthorizationServicer(auth_service), server
    )
    server.add_insecure_port(f'{host}:{port}')
    await server.start()
    print(f"Authorization server started on {host}:{port}")
    await server.wait_for_termination()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    
    # Initialize the authorization service with OpenFGA
    auth_service = AuthorizationService(
        api_host="https://api.fga.example",
        api_token="your_api_token", 
        store_id="your_store_id"
    )
    
    # Run the gRPC server
    asyncio.run(serve("0.0.0.0", 50051, auth_service))