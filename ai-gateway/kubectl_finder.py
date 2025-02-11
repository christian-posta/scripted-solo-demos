#!/usr/bin/env python3

"""
kubectl_finder.py

This script scans a specified shell script for 'kubectl apply' commands and allows the user to execute a selected command.

Usage:
    ./kubectl_finder.py <script.sh> [--run <command_index>] [-y]

Arguments:
    <script.sh>          The path to the shell script to analyze.
    --run <command_index> Specify the index of the 'kubectl apply' command to run.
    -y                   Automatically run the command without prompting for confirmation.

Examples:
    1. To find and list all 'kubectl apply' commands in a script:
       ./kubectl_finder.py 01-demo-hidecred.sh

    2. To run the first 'kubectl apply' command found:
       ./kubectl_finder.py 01-demo-hidecred.sh --run 0

    3. To run the first 'kubectl apply' command without confirmation:
       ./kubectl_finder.py 01-demo-hidecred.sh --run 0 -y
"""

import re
import sys
import subprocess

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <script.sh> [--run <command_index>] [-y]")
        sys.exit(1)

    script_path = sys.argv[1]
    run_command_index = None
    auto_run = '-y' in sys.argv  # Check if -y is in the arguments

    # Check for the --run argument
    if '--run' in sys.argv:
        try:
            run_command_index = int(sys.argv[sys.argv.index('--run') + 1])
        except (ValueError, IndexError):
            print("Error: Command index must be an integer and provided after --run.")
            sys.exit(1)

    # Regex to match kubectl apply commands
    kubectl_pattern = re.compile(r'kubectl\s+apply\s+-f\s+([^"\s]+)')

    kubectl_commands = []

    # Read the script line by line and collect matching commands
    with open(script_path, 'r') as script_file:
        for line in script_file:
            line = line.strip()  # remove leading/trailing whitespace
            
            # Check for kubectl commands
            kubectl_match = kubectl_pattern.search(line)
            if kubectl_match:
                kubectl_commands.append(kubectl_match.group(0))

    # Print out the collected kubectl commands with numbering
    if kubectl_commands:
        print("Found the following kubectl apply commands in the script:")
        for index, cmd in enumerate(kubectl_commands):
            print(f"[{index}] -- {cmd}")
        
        # If a command index is specified, run that command
        if run_command_index is not None:
            if 0 <= run_command_index < len(kubectl_commands):
                cmd_to_run = kubectl_commands[run_command_index]
                print(f"Command to run: {cmd_to_run}")

                # Always run the command if -y is passed
                if auto_run:
                    print(f"Running command: {cmd_to_run}")
                    try:
                        subprocess.run(cmd_to_run, shell=True, check=True)
                        print("Command executed successfully.")
                    except subprocess.CalledProcessError as e:
                        print(f"Error executing command: {e}")
                else:
                    # Prompt for confirmation if -y is not passed
                    choice = input("Do you want to run this command? (Y/n, default is Y): ").strip().lower() or 'y'
                    if choice == 'y':
                        print(f"Running command: {cmd_to_run}")
                        try:
                            subprocess.run(cmd_to_run, shell=True, check=True)
                            print("Command executed successfully.")
                        except subprocess.CalledProcessError as e:
                            print(f"Error executing command: {e}")
                    else:
                        print("Skipping command.")
            else:
                print(f"Error: Command index {run_command_index} is out of range.")
    else:
        print("No kubectl apply commands found in the script.")

if __name__ == "__main__":
    main() 