I want you to build a shell script for me. The purpose of the script is to manage tmux sessions, both currently running and future sessions.

The currently running should come from the `tmux list-sessions` command.

The future sessions should come from reading the `~/Projects/projects.yml` and `~/Work/projects.yml` files. They are in the form of:
```yaml
projects:
	flutter/18xx: ~/Projects/18XX
	flutter/bankbuilder: ~/Projects/BankBuilder
```
The first item is the name of the project, the second line the path of the project.

- The script should read both the active session list and the project lists from the two files. If it finds the name of a project from the files in the list of active sessions, remove the item from the future project list.
- Every project name in the Work project file should be automatically prefix with `work/`.
- Display the list to me with the `fzf` program and pass in the `--reverse flag` Display active sessions first, and then future projects.
- Prefix in the list every active project with `*` to indicate that this is an active session
- If I select a active project, switch to the session with `tmux switch-client -t`
- If I select an future project, create a new session that is named same as the name in the project list (with the work prefix), change the working directory of that session to the specified directory in the project file, and switch to it

Expect this script to be called on a tmux hotkey. It is replacing this binding that I have currently:
```
bind-key S display-popup -E "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux switch-client -t"
```

