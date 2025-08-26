`home-manager/scripts/worktree.py`

# Modify a python script

The python script we want to modify is `home-manager/scripts/worktree.py`. It is invoked with shell commands defined in `home-manager/programs/zsh.nix`

## Functionality to modify

We want to add functionality when adding a worktree, implemented in add_worktree. 

## Functionality to add
If the branch name is not develop, release, or master we want to figure out what what is the nearest ancestor branch currently available checked out in a worktree. It could be develop, release, master or some other branche currently checked out.

Once we have found the checked out root branch, compare the following files between the branches
- package.json
- targets/mobile/package.json
- targets/mobile/config.xml
  
If the new worktree branch has a unmodified package.json from the root worktree, do a hard link from ROOT_BRANCH/node_modules to NEW_BRANCH/node_modules. If it has been modified, echo that changes in package.json are detected.

Similarly, check for changes in the files target/mobile/package.json and targets/mobile/config.xml. If there are no changes detected in both files, hard symlink the following
- ROOT_BRANCH/targets/mobile/node_modules -> NEW_BRANCH/targets/mobile/node_modules
- ROOT_BRANCH/targets/mobile/platforms -> NEW_BRANCH/targets/mobile/platforms
- ROOT_BRANCH/targets/mobile/plugins -> NEW_BRANCH/targets/mobile/plugins

If there are changes detected, echo that changes are detected in targets/mobile/package.json and targets/moible/config.xml

IMPORTANT: The BRANCH names on the file system could be the same as the git branch name, or user defined.

## Architecture
Put the new functionality inside a new function in the script that is called from add_worktree.

