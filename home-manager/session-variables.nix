{ pkgs, ... }: {
  home.sessionVariables = {
    PAGER = "less -R";
    BAT_PAGER = "less -R";
    CLICLOLOR = 1;
    EDITOR = "hx";
  };
}