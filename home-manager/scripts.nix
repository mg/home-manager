{pkgs, ...}: {
  home = {
    file."./.local/bin/scriptlog" = {
       source = ./scripts/view-scriptlog.sh;
       executable = true;
    };
    file."./.local/bin/open-duckdb" = {
       source = ./scripts/open-duckdb.py;
       executable = true;
    };
    file."./.local/bin/open-rainfrog" = {
       source = ./scripts/open-rainfrog.py;
       executable = true;
    };
  };
}
