#!/usr/bin/env uv run python

import json
import os
import subprocess
import sys
from mg_telemetry import log_execution
from mg_nix import find_executable


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
    psql_binary = find_executable("psql", "postgresql")

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
