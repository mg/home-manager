{pkgs, ...}: {
  home = {
    # scripting libraries 
    file.".local/lib/system" = {
      source = ./scripts/lib;
      recursive = true;
    };

    # scripts
    file."./.local/bin/scriptlog" = {
       source = ./scripts/view-scriptlog.py;
       executable = true;
    };
    file."./.local/bin/open-duckdb" = {
       source = ./scripts/open-duckdb.py;
       executable = true;
    };
    file."./.local/bin/open-psql" = {
       source = ./scripts/open-psql.py;
       executable = true;
    };
    file."./.local/bin/open-rainfrog" = {
       source = ./scripts/open-rainfrog.py;
       executable = true;
    };
    file."./.local/bin/worktree" = {
       source = ./scripts/worktree.py;
       executable = true;
    };
    file."./.local/bin/open-pr" = {
       source = ./scripts/open-pr.py;
       executable = true;
    };
    file."./.local/bin/release-log" = {
       source = ./scripts/release-log.py;
       executable = true;
    };
    file."./.local/bin/tmux-session-manage" = {
       source = ./scripts/tmux-session-manage.sh;
       executable = true;
    };
  };
}
