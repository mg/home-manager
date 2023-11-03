{ pkgs, ... }: 
let 
  zellij-monocole = builtins.fetchurl {
    url = "https://github.com/imsnif/monocle/releases/download/0.37.2/monocle.wasm";
    sha256 = "03mpydx1k90fpqm2lf8v98mgssp4fzm9yvhm9f07avzqkxbfsiy0";
  };
in 
  {
    home.file.".config/zellij/plugins/monocle.wasm".source = zellij-monocole;
  }
