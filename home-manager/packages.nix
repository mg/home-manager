{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nb
    zsh-forgit # https://github.com/wfxr/forgit, https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/shells/zsh/zsh-forgit/default.nix#L51
    zsh-fzf-history-search
    zsh-fzf-tab
    lazydocker
    tldr

    # modern unix: https://github.com/ibraheemdev/modern-unix 
    choose
    delta
    less
    cheat # https://github.com/cheat/cheat
    glances
    hyperfine
    gping
    lsd # https://github.com/lsd-rs/lsd

    # shells
    # xonsh # https://xon.sh/

    # terminal
    zellij # https://zellij.dev/
    wtf # https://wtfutil.com/

    # file managers & file system tools
    nnn # https://github.com/jarun/nnn
    tree
    ranger # https://ranger.github.io/
    # broot # https://dystroy.org/broot/
    lf # https://pkg.go.dev/github.com/gokcehan/lf
    mc # https://midnight-commander.org/
    eza # https://github.com/eza-community/eza
    entr # https://eradman.com/entrproject/
    renameutils # https://www.nongnu.org/renameutils/

    # search
    silver-searcher # https://github.com/ggreer/the_silver_searcher
    fd # https://github.com/sharkdp/fd
    ripgrep # https://github.com/BurntSushi/ripgrep

    # downloaders
    wget
    curl
    youtube-dl
    rclone # https://rclone.org/

    # monitoring
    iftop # network monitoring
    bottom
    htop
    gtop
    btop
    procs # https://github.com/dalance/procs

    # disk tools
    duf
    du-dust
    ncdu # https://dev.yorhel.nl/ncdu

    # text tools
    helix # https://helix-editor.com/
    sad # https://github.com/ms-jpq/sad

    # image tools
    imagemagick

    # file viewers
    glow

    # log tools
    tailspin # https://github.com/bensadeh/tailspin
    lnav # https://lnav.org/

    # system tools
    pciutils # lspci
    keychain # https://www.funtoo.org/Funtoo:Keychain
    trippy # https://trippy.cli.rs/

    # terminal recording 
    asciinema # https://asciinema.org/
    asciinema-agg # https://github.com/asciinema/agg

    # software development
    lazygit
    tig # https://jonas.github.io/tig/
    gh # https://cli.github.com/
    tig
    httpie
    jq # https://jqlang.github.io/jq/
    jqp # https://github.com/noahgorstein/jqp
    jql # https://github.com/yamafaktory/jql
    fastgron # https://github.com/adamritter/fastgron
    fx # https://fx.wtf/
    ast-grep # https://ast-grep.github.io/

    # nix tools
    nix-output-monitor # https://github.com/maralorn/nix-output-monitor
    nixpkgs-fmt # code formatter
  ];
}
