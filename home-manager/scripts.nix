{pkgs, ...}: {
  home = {
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
