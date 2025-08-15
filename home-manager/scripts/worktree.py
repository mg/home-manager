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


def add_worktree(branch, name=None):
    """Add a worktree for branch at ../name (or ../branch if name is None), or cd to existing one"""
    dir_name = name if name else branch
    if worktree_exists(dir_name):
        print(
            f"Worktree '{dir_name}' already exists. Use 'cd ../{dir_name}' to navigate to it."
        )
        print(f"cd ../{dir_name}")
    else:
        print(f"Creating new worktree for branch '{branch}' at '../{dir_name}'...")

        # Check if local branch exists
        if branch_exists(branch):
            print(f"Local branch '{branch}' exists, using existing branch...")
            result = run_command(["git", "worktree", "add", f"../{dir_name}", branch])
        else:
            print(f"Creating new branch '{branch}' from origin/{branch}...")
            result = run_command(
                ["git", "worktree", "add", "-b", branch, f"../{dir_name}", f"origin/{branch}"]
            )

        if result and result.returncode == 0:
            print(f"Worktree for branch '{branch}' created successfully at '../{dir_name}'!")
            print(f"cd ../{dir_name}")
        else:
            print(f"Failed to create worktree for branch '{branch}' at '../{dir_name}'")
            if result:
                print(f"Error: {result.stderr}")
                # If branch creation failed, try without -b flag
                if "already exists" in result.stderr:
                    print(f"Trying to use existing local branch '{branch}'...")
                    result2 = run_command(
                        ["git", "worktree", "add", f"../{dir_name}", branch]
                    )
                    if result2 and result2.returncode == 0:
                        print(
                            f"Worktree for branch '{branch}' created successfully using existing branch at '../{dir_name}'!"
                        )
                        print(f"cd ../{dir_name}")
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


def get_current_worktree():
    """Return the absolute path of the current worktree (cwd)"""
    result = run_command(["git", "rev-parse", "--show-toplevel"])
    if result and result.returncode == 0:
        return result.stdout.strip()
    return None


def switch_worktree():
    """fzf select a worktree (except current), emit cd command"""
    # Get all worktrees
    result = run_command(["git", "worktree", "list", "--porcelain"])
    if not result or result.returncode != 0:
        print("Failed to list worktrees")
        if result:
            print(f"Error: {result.stderr}")
        return
    current = get_current_worktree()
    # Parse worktree paths
    worktrees = []
    for line in result.stdout.strip().split("\n"):
        if line.startswith("worktree "):
            path = line.replace("worktree ", "").strip()
            if path != current:
                worktrees.append(path)
    if not worktrees:
        print("No other worktrees to switch to.")
        return
    # Pipe to fzf
    try:
        fzf = subprocess.run(["fzf"], input="\n".join(worktrees), capture_output=True, text=True)
        selected = fzf.stdout.strip()
        if selected:
            print(f"cd {selected}")
    except Exception as e:
        print(f"Error running fzf: {e}")


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
        print("  switch        - Fuzzy switch to another worktree (fzf)")
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == "add":
        if len(sys.argv) < 3:
            print("Error: 'add' command requires at least a branch parameter")
            sys.exit(1)
        branch = sys.argv[2]
        name = sys.argv[3] if len(sys.argv) > 3 else None
        add_worktree(branch, name)

    elif command == "remove":
        if len(sys.argv) < 3:
            print("Error: 'remove' command requires a name parameter")
            sys.exit(1)
        name = sys.argv[2]
        remove_worktree(name)

    elif command == "list":
        list_worktrees()

    elif command == "switch":
        switch_worktree()

    else:
        print(f"Unknown command: {command}")
        print("Available commands: add, remove, list, switch")
        sys.exit(1)


if __name__ == "__main__":
    main()
