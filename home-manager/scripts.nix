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
  };
}
