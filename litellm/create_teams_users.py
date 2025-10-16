#!/usr/bin/env python3
"""
Script to create teams and users in LiteLLM Proxy via REST API

This script creates:
1. API keys for programmatic access (curl, SDKs, etc.)
2. Passwords for UI login at http://0.0.0.0:4000/ui

Note: Passwords are set via /user/update endpoint after user creation.
"""

import requests
import sys
from typing import Dict, List, Optional
from datetime import datetime

# Configuration
PROXY_BASE_URL = "http://0.0.0.0:4000"
ADMIN_API_KEY = "sk-1234"
OUTPUT_FILE = "virtual-keys.txt"  # File to save generated API keys

# Headers for API requests
HEADERS = {
    "Authorization": f"Bearer {ADMIN_API_KEY}",
    "Content-Type": "application/json"
}

# ============================================================================
# TEAMS CONFIGURATION
# ============================================================================
TEAMS = [
    {
        "team_alias": "Supply Chain",
        
        # MODEL ACCESS
        # Empty list = access to ALL models
        # To restrict, use model names from your config:
        # "models": ["gpt-3.5-turbo", "claude-3-haiku", "gemini-2.5-flash"],
        "models": [],
        
        # BUDGETS (currently disabled)
        # Uncomment and set values to enable:
        # "max_budget": 100.0,           # Max $100 USD spend
        # "budget_duration": "30d",      # Resets every 30 days
        # "soft_budget": 80.0,           # Alert at $80 (doesn't block)
        "max_budget": None,
        "budget_duration": None,
        
        # RATE LIMITS (currently disabled)
        # Uncomment and set values to enable:
        # "rpm_limit": 1000,             # Max 1000 requests per minute
        # "tpm_limit": 500000,           # Max 500K tokens per minute
        # "max_parallel_requests": 50,   # Max 50 concurrent requests
    },
    {
        "team_alias": "HR",
        "models": ["gpt-3.5-turbo", "claude-3-haiku", "gemini-2.5-flash", "gemini-2.5-flash-lite"],  # All models allowed
        
        # BUDGET EXAMPLE (commented out):
        # "max_budget": 50.0,            # $50 monthly budget
        # "budget_duration": "30d",      # Monthly reset
        "max_budget": None,
        "budget_duration": None,
        
        # RATE LIMIT EXAMPLE (commented out):
        # "rpm_limit": 500,              # 500 requests/min
        # "tpm_limit": 250000,           # 250K tokens/min
    }
]

# ============================================================================
# USERS CONFIGURATION
# ============================================================================
USERS = [
    {
        "user_id": "supply-chain@solo.io",
        "user_email": "supply-chain@solo.io",
        "user_role": "internal_user",  # Can create/delete own keys, view spend
        
        # PASSWORD (for UI login)
        "password": "sk-1234",  # Password for logging into LiteLLM UI
        
        # TEAM ASSIGNMENT
        "teams": ["Supply Chain"],  # Assigned to Supply Chain team
        
        # MODEL ACCESS
        # Empty list = inherits from team OR access to all models
        # To restrict at user level, specify models:
        # "models": ["gpt-3.5-turbo", "claude-3-5-sonnet", "gemini-2.5-flash-lite"],
        "models": [],
        
        # USER BUDGETS (currently disabled)
        # Uncomment to set user-specific budget:
        # "max_budget": 25.0,            # $25 personal budget
        # "budget_duration": "7d",       # Weekly reset
        # "soft_budget": 20.0,           # Alert at $20
        
        # USER RATE LIMITS (currently disabled)
        # Uncomment to set user-specific rate limits:
        # "rpm_limit": 100,              # 100 requests per minute
        # "tpm_limit": 50000,            # 50K tokens per minute
        # "max_parallel_requests": 10,   # Max 10 concurrent requests
    },
    {
        "user_id": "aws-user@solo.io",
        "user_email": "aws-user@solo.io",
        "user_role": "internal_user",
        
        # PASSWORD (for UI login)
        "password": "sk-1234",  # Password for logging into LiteLLM UI
        
        # TEAM ASSIGNMENT
        "teams": [],  # Not assigned to any team - independent user
        
        # MODEL ACCESS - Example of restricting to specific models:
        # "models": ["bedrock-claude-4-sonnet", "gpt-3.5-turbo"],
        "models": ["bedrock-claude-4-sonnet"],  # All models allowed for now
        
        # RATE LIMIT EXAMPLE for high-traffic user (commented out):
        # "rpm_limit": 2000,             # Higher limit for AWS user
        # "tpm_limit": 1000000,          # 1M tokens/min
    },
    {
        "user_id": "hr@solo.io",
        "user_email": "hr@solo.io",
        "user_role": "internal_user",
        
        # PASSWORD (for UI login)
        "password": "sk-1234",  # Password for logging into LiteLLM UI
        
        # TEAM ASSIGNMENT
        "teams": ["HR"],  # Assigned to HR team
        
        # MODEL ACCESS - Example of restricting to smaller/cheaper models:
        # "models": ["gpt-3.5-turbo", "claude-3-haiku", "gemini-2.5-flash-lite"],
        "models": [],
        
        # BUDGET EXAMPLE for cost control (commented out):
        # "max_budget": 10.0,            # $10 budget
        # "budget_duration": "30d",      # Monthly
    }
]

# ============================================================================
# Available Models (from your config.yaml)
# ============================================================================
# Use these model names when restricting access:
# - "gpt-3.5-turbo"
# - "gpt-3.5-turbo-instruct"
# - "claude-3-5-sonnet"
# - "claude-3-haiku"
# - "claude-sonnet-4"
# - "gemini-2.5-flash-lite"
# - "gemini-2.5-flash"
# - "bedrock-claude-4-sonnet"
# ============================================================================


def create_team(team_data: Dict) -> Optional[Dict]:
    """Create a new team via /team/new endpoint"""
    url = f"{PROXY_BASE_URL}/team/new"
    
    payload = {
        "team_alias": team_data["team_alias"],
    }
    
    # Add optional fields if present
    if team_data.get("models"):
        payload["models"] = team_data["models"]
    if team_data.get("max_budget") is not None:
        payload["max_budget"] = team_data["max_budget"]
    if team_data.get("budget_duration"):
        payload["budget_duration"] = team_data["budget_duration"]
    if team_data.get("soft_budget"):
        payload["soft_budget"] = team_data["soft_budget"]
    if team_data.get("rpm_limit"):
        payload["rpm_limit"] = team_data["rpm_limit"]
    if team_data.get("tpm_limit"):
        payload["tpm_limit"] = team_data["tpm_limit"]
    if team_data.get("max_parallel_requests"):
        payload["max_parallel_requests"] = team_data["max_parallel_requests"]
    
    try:
        response = requests.post(url, json=payload, headers=HEADERS)
        response.raise_for_status()
        team = response.json()
        print(f"✅ Created team: {team['team_alias']} (ID: {team['team_id']})")
        return team
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to create team '{team_data['team_alias']}': {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"   Response: {e.response.text}")
        return None


def create_user(user_data: Dict, team_id_map: Dict[str, str]) -> Optional[Dict]:
    """Create a new user via /user/new endpoint"""
    url = f"{PROXY_BASE_URL}/user/new"
    
    # Map team names to team IDs
    team_ids = []
    for team_name in user_data.get("teams", []):
        if team_name in team_id_map:
            team_ids.append(team_id_map[team_name])
        else:
            print(f"⚠️  Warning: Team '{team_name}' not found for user {user_data['user_id']}")
    
    payload = {
        "user_id": user_data["user_id"],
        "user_email": user_data["user_email"],
        "user_role": user_data.get("user_role", "internal_user"),
        "auto_create_key": False,  # Don't auto-create key - we'll create team-scoped keys instead
    }
    
    # Add optional fields
    if team_ids:
        payload["teams"] = team_ids
    if user_data.get("models"):
        payload["models"] = user_data["models"]
    if user_data.get("max_budget") is not None:
        payload["max_budget"] = user_data["max_budget"]
    if user_data.get("budget_duration"):
        payload["budget_duration"] = user_data["budget_duration"]
    if user_data.get("soft_budget"):
        payload["soft_budget"] = user_data["soft_budget"]
    if user_data.get("rpm_limit"):
        payload["rpm_limit"] = user_data["rpm_limit"]
    if user_data.get("tpm_limit"):
        payload["tpm_limit"] = user_data["tpm_limit"]
    if user_data.get("max_parallel_requests"):
        payload["max_parallel_requests"] = user_data["max_parallel_requests"]
    
    try:
        response = requests.post(url, json=payload, headers=HEADERS)
        response.raise_for_status()
        user = response.json()
        print(f"✅ Created user: {user['user_id']}")
        print(f"   API Key: {user.get('key', 'N/A')}")
        if user.get('expires'):
            print(f"   Expires: {user['expires']}")
        return user
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to create user '{user_data['user_id']}': {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"   Response: {e.response.text}")
        return None


def create_team_scoped_key(user_id: str, team_id: str, team_name: str, models: List[str]) -> Optional[Dict]:
    """Create a team-scoped API key via /key/generate endpoint
    
    This ensures the key has team_id set, so it inherits team model restrictions.
    """
    url = f"{PROXY_BASE_URL}/key/generate"
    
    payload = {
        "user_id": user_id,
        "team_id": team_id,
        "models": models if models else [],  # Empty = inherits from team
        "key_alias": f"{user_id}-{team_name.lower().replace(' ', '-')}-key",
    }
    
    try:
        response = requests.post(url, json=payload, headers=HEADERS)
        response.raise_for_status()
        key_data = response.json()
        print(f"   🔑 Created team-scoped key for team '{team_name}'")
        return key_data
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Failed to create team key for '{user_id}' in team '{team_name}': {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"      Response: {e.response.text}")
        return None


def create_personal_key(user_id: str, models: List[str]) -> Optional[Dict]:
    """Create a personal API key via /key/generate endpoint
    
    For users not in teams. Must explicitly set models list to enforce restrictions.
    """
    url = f"{PROXY_BASE_URL}/key/generate"
    
    payload = {
        "user_id": user_id,
        "models": models,  # Must be explicit for personal keys
        "key_alias": f"{user_id}-personal-key",
    }
    
    try:
        response = requests.post(url, json=payload, headers=HEADERS)
        response.raise_for_status()
        key_data = response.json()
        print(f"   🔑 Created personal key with {len(models) if models else 'all'} model(s)")
        return key_data
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Failed to create personal key for '{user_id}': {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"      Response: {e.response.text}")
        return None


def set_user_password(user_id: str, password: str) -> bool:
    """Set password for a user via /user/update endpoint"""
    url = f"{PROXY_BASE_URL}/user/update"
    
    payload = {
        "user_id": user_id,
        "password": password,
    }
    
    try:
        response = requests.post(url, json=payload, headers=HEADERS)
        response.raise_for_status()
        print(f"   🔑 Set password for user: {user_id}")
        return True
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Failed to set password for '{user_id}': {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"      Response: {e.response.text}")
        return False


def save_keys_to_file(users: List[Dict], filename: str):
    """Save generated API keys to a file (overwrites existing file)"""
    try:
        with open(filename, 'w') as f:
            f.write("=" * 80 + "\n")
            f.write("LiteLLM Virtual API Keys\n")
            f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 80 + "\n\n")
            
            f.write("IMPORTANT NOTES:\n")
            f.write("-" * 80 + "\n")
            f.write("1. API Keys: For programmatic access (curl, SDKs, etc.)\n")
            f.write("2. Passwords: For UI login at http://0.0.0.0:4000/ui\n")
            f.write("3. Team-scoped keys inherit model restrictions from their team\n")
            f.write("4. Personal keys have explicit model lists (empty = all models)\n")
            f.write("5. Keep these credentials secure - they grant access to LiteLLM proxy\n\n")
            
            f.write("=" * 80 + "\n")
            f.write("USER CREDENTIALS & API KEYS\n")
            f.write("=" * 80 + "\n\n")
            
            for user in users:
                user_id = user.get('user_id', 'Unknown')
                password = user.get('password', 'Not set')
                keys = user.get('keys', [])
                
                f.write(f"User: {user_id}\n")
                f.write(f"Password: {password}\n")
                f.write(f"Number of Keys: {len(keys)}\n")
                f.write("\n")
                
                for idx, key_info in enumerate(keys, 1):
                    key_type = key_info.get('type', 'unknown')
                    f.write(f"  Key #{idx}:\n")
                    f.write(f"    Type: {key_type}\n")
                    f.write(f"    API Key: {key_info.get('key', 'N/A')}\n")
                    f.write(f"    Alias: {key_info.get('key_alias', 'N/A')}\n")
                    
                    if key_type == 'team-scoped':
                        f.write(f"    Team: {key_info.get('team', 'N/A')}\n")
                        f.write(f"    Model Access: Inherits from team\n")
                    elif key_type == 'personal':
                        models = key_info.get('models', [])
                        model_str = ', '.join(models) if models else 'All models'
                        f.write(f"    Team: None (personal key)\n")
                        f.write(f"    Model Access: {model_str}\n")
                    f.write("\n")
                
                f.write("-" * 80 + "\n\n")
            
            f.write("\n")
            f.write("=" * 80 + "\n")
            f.write("USAGE EXAMPLES\n")
            f.write("=" * 80 + "\n\n")
            
            if users and users[0].get('keys'):
                example_key = users[0]['keys'][0].get('key', 'YOUR_API_KEY')
                f.write("Example 1: Test with curl\n")
                f.write(f"""
curl -X POST '{PROXY_BASE_URL}/v1/chat/completions' \\
  -H 'Content-Type: application/json' \\
  -H 'Authorization: Bearer {example_key}' \\
  -d '{{
    "model": "gpt-3.5-turbo",
    "messages": [{{"role": "user", "content": "Hello!"}}]
  }}'
\n""")
                
                f.write("\nExample 2: Python SDK\n")
                f.write(f"""
from openai import OpenAI

client = OpenAI(
    api_key="{example_key}",
    base_url="{PROXY_BASE_URL}/v1"
)

response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{{"role": "user", "content": "Hello!"}}]
)
\n""")
        
        print(f"\n💾 API keys saved to: {filename}")
        
    except Exception as e:
        print(f"\n❌ Failed to save keys to file: {e}")


def main():
    """Main function to create teams and users"""
    print("=" * 80)
    print("LiteLLM Proxy - Team and User Creation Script")
    print("=" * 80)
    print(f"Proxy URL: {PROXY_BASE_URL}")
    print(f"Admin Key: {ADMIN_API_KEY}")
    print(f"Output File: {OUTPUT_FILE}")
    print()
    
    # Step 1: Create teams
    print("📋 Creating Teams...")
    print("-" * 80)
    team_id_map = {}  # Maps team_alias -> team_id
    
    for team_data in TEAMS:
        team = create_team(team_data)
        if team:
            team_id_map[team['team_alias']] = team['team_id']
    
    print()
    
    # Step 2: Create users
    print("👥 Creating Users...")
    print("-" * 80)
    
    created_users = []
    for user_data in USERS:
        user = create_user(user_data, team_id_map)
        if user:
            user_info = {
                "user_id": user['user_id'],
                "user_email": user.get('user_email'),
                "keys": [],
                "password": None,
                "teams": user_data.get("teams", [])
            }
            
            # Set password if provided
            if user_data.get("password"):
                if set_user_password(user['user_id'], user_data["password"]):
                    user_info['password'] = user_data["password"]
            
            # Create appropriate key based on team membership
            user_teams = user_data.get("teams", [])
            user_models = user_data.get("models", [])
            
            if user_teams:
                # User has team(s) - create team-scoped key
                for team_name in user_teams:
                    if team_name in team_id_map:
                        key_data = create_team_scoped_key(
                            user_id=user['user_id'],
                            team_id=team_id_map[team_name],
                            team_name=team_name,
                            models=user_models
                        )
                        if key_data:
                            user_info['keys'].append({
                                "key": key_data.get('key') or key_data.get('token'),
                                "team": team_name,
                                "type": "team-scoped",
                                "key_alias": key_data.get('key_alias')
                            })
            else:
                # User has no team - create personal key with explicit models
                key_data = create_personal_key(
                    user_id=user['user_id'],
                    models=user_models
                )
                if key_data:
                    user_info['keys'].append({
                        "key": key_data.get('key') or key_data.get('token'),
                        "team": None,
                        "type": "personal",
                        "models": user_models,
                        "key_alias": key_data.get('key_alias')
                    })
            
            if user_info['keys']:  # Only add if we successfully created at least one key
                created_users.append(user_info)
    
    print()
    
    # Step 3: Save keys to file
    if created_users:
        save_keys_to_file(created_users, OUTPUT_FILE)
    
    # Step 4: Summary
    print()
    print("=" * 80)
    print("📊 Summary")
    print("=" * 80)
    print(f"Teams created: {len(team_id_map)}/{len(TEAMS)}")
    print(f"Users created: {len(created_users)}/{len(USERS)}")
    print()
    
    if created_users:
        print("🔑 User API Keys:")
        print("-" * 80)
        for user in created_users:
            user_id = user['user_id']
            keys = user.get('keys', [])
            
            for key_info in keys:
                key_type = key_info.get('type', 'unknown')
                api_key = key_info.get('key', 'N/A')
                
                if key_type == 'team-scoped':
                    team = key_info.get('team', 'Unknown')
                    print(f"  {user_id} (Team: {team}): {api_key}")
                elif key_type == 'personal':
                    models = key_info.get('models', [])
                    model_info = f"{len(models)} model(s)" if models else "all models"
                    print(f"  {user_id} (Personal - {model_info}): {api_key}")
        print()
    
    print("💡 Next Steps:")
    print("-" * 80)
    print(f"1. Credentials saved to: {OUTPUT_FILE}")
    print(f"2. UI Login: {PROXY_BASE_URL}/ui")
    print("   - Use user email as username")
    print("   - Use the password from the output file")
    print("3. Test API access with the examples in virtual-keys.txt")
    print(f"4. Monitor usage at: {PROXY_BASE_URL}/ui")
    print()
    print("✨ Done!")
    
    # Return exit code based on success
    if len(team_id_map) == len(TEAMS) and len(created_users) == len(USERS):
        return 0
    else:
        return 1


if __name__ == "__main__":
    sys.exit(main())