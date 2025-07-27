#!/usr/bin/env uv run python

import json
import os
import subprocess
import sys
import tempfile


def main():
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

    # Generate DuckDB initialization commands
    init_commands = []

    # Install and load the appropriate extension
    if db_type == "postgres" or db_type == "postgresql":
        init_commands.extend(["INSTALL postgres;", "LOAD postgres;"])
        # Create connection string for PostgreSQL
        conn_string = f"host={host} port={port} dbname={database} user={user}"
        if password:
            conn_string += f" password={password}"
        attach_command = f"ATTACH 'dbname={database} host={host} port={port} user={user} password={password}' AS pg (TYPE POSTGRES);"
    elif db_type == "mysql":
        init_commands.extend(["INSTALL mysql;", "LOAD mysql;"])
        attach_command = f"ATTACH 'host={host} port={port} database={database} user={user} password={password}' AS mysql_db (TYPE MYSQL);"
    elif db_type == "sqlite":
        # SQLite doesn't need separate install/load
        attach_command = f"ATTACH '{database}' AS sqlite_db;"
    else:
        print(f"Error: Unsupported database type: {db_type}")
        sys.exit(1)

    # Add the ATTACH command
    init_commands.append(attach_command)

    # Create a temporary init file
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".sql", delete=False
    ) as temp_file:
        temp_file.write("\n".join(init_commands))
        temp_file_path = temp_file.name

    try:
        # Start DuckDB with the initialization file
        print(f"Starting DuckDB with {db_type} connection...")
        print("Initialization commands:")
        for cmd in init_commands:
            print(f"  {cmd}")
        print()

        # Execute DuckDB with the init file
        subprocess.run(["duckdb", "-init", temp_file_path], check=True)

    except subprocess.CalledProcessError as e:
        print(f"Error running DuckDB: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print(
            "Error: 'duckdb' command not found. Please ensure DuckDB is installed and in your PATH."
        )
        sys.exit(1)
    finally:
        # Clean up the temporary file
        try:
            os.unlink(temp_file_path)
        except OSError:
            pass


if __name__ == "__main__":
    main()
