#!/usr/bin/env uv run python

import json
import os
import subprocess
import sys
from pathlib import Path
import re
from mg_telemetry import log_execution


def find_psql_in_direnv():
    """Find psql binary by looking for .direnv folder and nix-profile files"""
    current_dir = Path.cwd()
    # print("Current dir : ", current_dir)

    # Walk up directories looking for .direnv
    while current_dir != current_dir.parent:
        direnv_path = current_dir / ".direnv"
        if direnv_path.exists() and direnv_path.is_dir():
            # print(f"found direnv at #{direnv_path}")
            # Look for files starting with nix-profile
            nix_profile_files = list(direnv_path.glob("nix-profile*"))

            for profile_file in nix_profile_files:
                try:
                    # print(f"open file #{profile_file}")
                    with open(profile_file, "r") as f:
                        content = f.read()
                    # print(f"read file #{profile_file}")

                    # Try to parse as JSON first (structured data)
                    try:
                        import json

                        data = json.loads(content)
                        if "variables" in data and "PATH" in data["variables"]:
                            path_value = data["variables"]["PATH"]["value"]
                            # Split PATH by colons and look for postgresql paths
                            for path_entry in path_value.split(":"):
                                if "postgresql" in path_entry:
                                    psql_path = os.path.join(path_entry, "psql")
                                    if os.path.exists(psql_path) and os.access(
                                        psql_path, os.X_OK
                                    ):
                                        return psql_path
                    except json.JSONDecodeError:
                        # Look for PATH export lines in shell format
                        path_matches = re.findall(r'export PATH="([^"]*)"', content)

                        for path_value in path_matches:
                            # Split PATH by colons and look for postgresql paths
                            for path_entry in path_value.split(":"):
                                if "postgresql" in path_entry:
                                    psql_path = os.path.join(path_entry, "psql")
                                    if os.path.exists(psql_path) and os.access(
                                        psql_path, os.X_OK
                                    ):
                                        return psql_path

                        # Also look for PATH directly in variables section
                        path_match = re.search(
                            r'"PATH":\s*{\s*"type":\s*"exported",\s*"value":\s*"([^"]*)"',
                            content,
                        )
                        if path_match:
                            path_value = path_match.group(1)
                            for path_entry in path_value.split(":"):
                                if "postgresql" in path_entry:
                                    psql_path = os.path.join(path_entry, "psql")
                                    if os.path.exists(psql_path) and os.access(
                                        psql_path, os.X_OK
                                    ):
                                        return psql_path

                except Exception:
                    # print("Exception")
                    continue

            # quit after processing first direnv path
            break

        current_dir = current_dir.parent

    return None


def main():
    # Log script execution
    log_execution(__file__)

    config_file = ".db.json"

    # Check if .db.json exists
    if not os.path.exists(config_file):
        print(f"Error: {config_file} not found in current directory")
        sys.exit(1)

    # Read and parse the configuration
    try:
        with open(config_file, "r") as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON in {config_file}: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading {config_file}: {e}")
        sys.exit(1)

    # Extract configuration values
    db_type = config.get("type", "").lower()
    host = config.get("host", "localhost")
    port = config.get("port", 5432)
    database = config.get("db", "")
    user = config.get("user", "")
    password = config.get("password", "")

    if not all([db_type, database, user]):
        print("Error: Missing required fields (type, db, user) in configuration")
        sys.exit(1)

    # Only support PostgreSQL for psql
    if db_type not in ["postgres", "postgresql"]:
        print(f"Error: This script only supports PostgreSQL databases, got: {db_type}")
        sys.exit(1)

    # Find psql binary
    psql_binary = find_psql_in_direnv()
    if not psql_binary:
        # Fall back to PATH
        psql_binary = "psql"

    # Build psql command
    psql_cmd = [psql_binary]

    # Add connection parameters
    psql_cmd.extend(["-h", host])
    psql_cmd.extend(["-p", str(port)])
    psql_cmd.extend(["-U", user])
    psql_cmd.extend(["-d", database])

    # Set environment variable for password if provided
    env = os.environ.copy()
    if password:
        env["PGPASSWORD"] = password

    try:
        print(
            f"Connecting to PostgreSQL database '{database}' on {host}:{port} as user '{user}'..."
        )

        # Execute psql
        subprocess.run(psql_cmd, env=env, check=True)

    except subprocess.CalledProcessError as e:
        print(f"Error running psql: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: 'psql' command not found. Please ensure PostgreSQL client is installed and in your PATH."
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
