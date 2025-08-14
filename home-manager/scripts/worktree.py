#!/usr/bin/env -S uv run python
import sys
import subprocess
from mg_telemetry import log_execution


def run_command(cmd, shell=False):
    """Run a command and return the result"""
    try:
        if shell:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        else:
            result = subprocess.run(cmd, capture_output=True, text=True)
        return result
    except Exception as e:
        print(f"Error running command: {e}")
        return None


def worktree_exists(name):
    """Check if a worktree with the given name exists"""
    result = run_command(["git", "worktree", "list", "--porcelain"])
    if result and result.returncode == 0:
        lines = result.stdout.strip().split("\n")
        for line in lines:
            if line.startswith("worktree "):
                worktree_path = line.replace("worktree ", "")
                if worktree_path.endswith(f"/{name}") or worktree_path.endswith(
                    f"\\{name}"
                ):
                    return True
    return False


def branch_exists(name):
    """Check if a local branch exists"""
    result = run_command(["git", "branch", "--list", name])
    return result and result.returncode == 0 and name in result.stdout


def add_worktree(name):
    """Add a worktree or cd to existing one"""
    if worktree_exists(name):
        print(
            f"Worktree '{name}' already exists. Use 'cd ../{name}' to navigate to it."
        )
        # Note: We can't actually cd from a script, so we print the command
        print(f"cd ../{name}")
    else:
        print(f"Creating new worktree '{name}'...")

        # Check if local branch exists
        if branch_exists(name):
            print(f"Local branch '{name}' exists, using existing branch...")
            result = run_command(["git", "worktree", "add", f"../{name}", name])
        else:
            print(f"Creating new branch '{name}' from origin/{name}...")
            result = run_command(
                ["git", "worktree", "add", "-b", name, f"../{name}", f"origin/{name}"]
            )

        if result and result.returncode == 0:
            print(f"Worktree '{name}' created successfully!")
            print(f"cd ../{name}")
        else:
            print(f"Failed to create worktree '{name}'")
            if result:
                print(f"Error: {result.stderr}")
                # If branch creation failed, try without -b flag
                if "already exists" in result.stderr:
                    print(f"Trying to use existing local branch '{name}'...")
                    result2 = run_command(
                        ["git", "worktree", "add", f"../{name}", name]
                    )
                    if result2 and result2.returncode == 0:
                        print(
                            f"Worktree '{name}' created successfully using existing branch!"
                        )
                        print(f"cd ../{name}")
                    else:
                        print(
                            f"Still failed: {result2.stderr if result2 else 'Unknown error'}"
                        )


def remove_worktree(name):
    """Remove a worktree"""
    if not worktree_exists(name):
        print(f"Worktree '{name}' does not exist.")
        return

    print(f"Removing worktree '{name}'...")
    result = run_command(["git", "worktree", "remove", f"../{name}"])

    if result and result.returncode == 0:
        print(f"Worktree '{name}' removed successfully!")
    else:
        print(f"Failed to remove worktree '{name}'")
        if result:
            print(f"Error: {result.stderr}")
            # Try force removal
            print("Attempting force removal...")
            result = run_command(["git", "worktree", "remove", "--force", f"../{name}"])
            if result and result.returncode == 0:
                print(f"Worktree '{name}' force removed successfully!")
            else:
                print("Force removal also failed.")


def list_worktrees():
    """List all worktrees"""
    result = run_command(["git", "worktree", "list"])

    if result and result.returncode == 0:
        print("Current worktrees:")
        print(result.stdout)
    else:
        print("Failed to list worktrees")
        if result:
            print(f"Error: {result.stderr}")


def main():
    # Log script execution
    log_execution(__file__)

    if len(sys.argv) < 2:
        print("Usage: script.py <command> [name]")
        print("Commands:")
        print("  add <name>    - Add worktree or navigate to existing one")
        print("  remove <name> - Remove worktree")
        print("  list          - List all worktrees")
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == "add":
        if len(sys.argv) < 3:
            print("Error: 'add' command requires a name parameter")
            sys.exit(1)
        name = sys.argv[2]
        add_worktree(name)

    elif command == "remove":
        if len(sys.argv) < 3:
            print("Error: 'remove' command requires a name parameter")
            sys.exit(1)
        name = sys.argv[2]
        remove_worktree(name)

    elif command == "list":
        list_worktrees()

    else:
        print(f"Unknown command: {command}")
        print("Available commands: add, remove, list")
        sys.exit(1)


if __name__ == "__main__":
    main()
