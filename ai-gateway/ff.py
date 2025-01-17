#!/usr/bin/env python3

import re
import subprocess
import sys

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <demo_script.sh>")
        sys.exit(1)

    demo_script_path = sys.argv[1]

    # Regex to match print_gateway_command with 5th parameter
    prompt_pattern = re.compile(r'^print_gateway_command\s+""\s+""\s+""\s+""\s+"([^"]+)"')
    
    # Regex to match kubectl apply commands
    kubectl_pattern = re.compile(r'^run\s+"(kubectl\s+apply\s+-f\s+[^"]+)"')

    prompts = []
    kubectl_commands = []

    # Read the demo script line by line and collect matching commands
    with open(demo_script_path, 'r') as demo_file:
        for line in demo_file:
            line = line.strip()  # remove leading/trailing whitespace
            
            # Check for prompts
            prompt_match = prompt_pattern.match(line)
            if prompt_match:
                prompts.append(prompt_match.group(1))
                
            # Check for kubectl commands
            kubectl_match = kubectl_pattern.match(line)
            if kubectl_match:
                kubectl_commands.append(kubectl_match.group(1))

    # Print prompts if any were found
    if prompts:
        print("Found the following prompts in the script:")
        for prompt in prompts:
            print(f"  {prompt}")
        print()

    # If no kubectl commands found, let the user know and exit
    if not kubectl_commands:
        print("No kubectl apply commands found in the script.")
        sys.exit(0)

    # Print out the collected kubectl commands
    print("Found the following kubectl apply commands in the script:")
    for cmd in kubectl_commands:
        print(f"  {cmd}")
        
    print("\nWill prompt for each command individually...")

    # Process each kubectl command individually
    for cmd in kubectl_commands:
        print(f"\nCommand to run: {cmd}")
        choice = input("Do you want to run this command? (Y/n, default is Y): ").strip().lower() or 'y'
        if choice == 'y':
            print(f"Running: {cmd}")
            try:
                subprocess.run(cmd, shell=True, check=True)
                print("Command executed successfully.")
            except subprocess.CalledProcessError as e:
                print(f"Error executing command: {e}")
                choice = input("Continue with remaining commands? (Y/n, default is Y): ").strip().lower() or 'y'
                if choice != 'y':
                    print("Exiting.")
                    sys.exit(1)
        else:
            print("Skipping command.")

    print("\nAll commands processed.")

if __name__ == "__main__":
    main()
