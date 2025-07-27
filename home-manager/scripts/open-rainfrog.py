#!/usr/bin/env uv run python

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def log_script_execution():
    """Log script execution to ~/.local/share/logs/scripts.csv"""
    log_dir = Path.home() / ".local" / "share" / "logs"
    log_file = log_dir / "scripts.csv"
    script_name = Path(__file__).stem  # Get filename without extension
    utc_time = datetime.utcnow().isoformat() + "Z"

    # Create log directory if it doesn't exist
    log_dir.mkdir(parents=True, exist_ok=True)

    # Write header if file doesn't exist
    if not log_file.exists():
        with open(log_file, "w") as f:
            f.write("timestamp,script\n")

    # Append log entry
    with open(log_file, "a") as f:
        f.write(f"{utc_time},{script_name}\n")


def main():
    # Log script execution
    log_script_execution()

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

    # Build connection string based on database type
    if db_type == "postgres" or db_type == "postgresql":
        # PostgreSQL connection string format
        conn_string = f"postgresql://{user}"
        if password:
            conn_string += f":{password}"
        conn_string += f"@{host}:{port}/{database}"
    elif db_type == "mysql":
        # MySQL connection string format
        conn_string = f"mysql://{user}"
        if password:
            conn_string += f":{password}"
        conn_string += f"@{host}:{port}/{database}"
    elif db_type == "sqlite":
        # SQLite connection string format
        conn_string = f"sqlite://{database}"
    else:
        print(f"Error: Unsupported database type: {db_type}")
        sys.exit(1)

    try:
        # Start Rainfrog with the connection string
        print(f"Starting Rainfrog with {db_type} connection...")
        print(f"Connection string: {conn_string}")
        print()

        # Execute Rainfrog with the connection string
        subprocess.run(["rainfrog", "--url", conn_string], check=True)

    except subprocess.CalledProcessError as e:
        print(f"Error running Rainfrog: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: 'rainfrog' command not found. Please ensure Rainfrog is installed and in your PATH."
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
