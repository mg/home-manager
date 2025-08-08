import os
import sys
from pathlib import Path
import re
import shutil
from mg_telemetry import get_logger

# usage
# from mg_nix import find_executable
# executable = find_executable("psql", "postgresql")


def find_executable(executable, marker):
    """Check if it is already in system path"""
    system_path = shutil.which(executable)
    if system_path:
        return system_path

    """Find executable by looking for .direnv folder and nix-profile files"""
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
                                if marker in path_entry:
                                    psql_path = os.path.join(path_entry, executable)
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

    logger = get_logger("nix/find_executable")
    logger.error(f"Executable '{executable}' not found (marker: '{marker}')")
    sys.exit(1)
