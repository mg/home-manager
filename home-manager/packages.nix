# https://github.com/rothgar/awesome-tuis
{pkgs, ...}: {
  home.packages = with pkgs; [
    nb
    zsh-forgit # https://github.com/wfxr/forgit, https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/shells/zsh/zsh-forgit/default.nix#L51
    zsh-fzf-history-search
    zsh-fzf-tab
    tldr
    fpp # https://github.com/facebook/pathpicker/
    # https://github.com/robertpsoane/ducker
    jira-cli-go # https://github.com/ankitpokhrel/jira-cli

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
    #jzellij # https://zellij.dev/
    # wtf # https://wtfutil.com/

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
    rm-improved # https://github.com/nivekuil/rip
    fswatch # https://github.com/emcrisostomo/fswatch
    # fex # https://github.com/18alantom/fex
    pls # https://pls.cli.rs/
    television # https://github.com/alexpasmantier/television
    superfile # https://superfile.netlify.app/

    # search
    silver-searcher # https://github.com/ggreer/the_silver_searcher
    fd # https://github.com/sharkdp/fd
    ripgrep # https://github.com/BurntSushi/ripgrep
    fselect # https://fselect.rocks/
    # serpl # https://github.com/yassinebridi/serpl

    # downloaders
    wget
    curl
    rclone # https://rclone.org/
    yt-dlp

    # monitoring
    iftop # network monitoring
    bottom
    htop
    gtop
    btop
    procs # https://github.com/dalance/procs
    zenith # https://github.com/bvaisvil/zenith

    # containers
    ctop # https://github.com/bcicen/ctop
    dive # https://github.com/wagoodman/dive
    lazydocker # https://github.com/jesseduffield/lazydocker
    # dry # https://github.com/moncho/dry

    # process management
    pueue # https://github.com/Nukesor/pueue

    # disk tools
    duf
    du-dust
    ncdu # https://dev.yorhel.nl/ncdu

    # network tools
    doggo # https://doggo.mrkaran.dev/docs/
    # impala # https://github.com/pythops/impala

    # text tools
    neovim # https://neovim.io/
    helix # https://helix-editor.com/
    sad # https://github.com/ms-jpq/sad
    gnused
    gawk

    # video & image tools
    gifski
    imagemagick

    # file viewers
    glow

    # log tools
    tailspin # https://github.com/bensadeh/tailspin
    #lnav # https://lnav.org/
    angle-grinder # https://github.com/rcoh/angle-grinder
    tabiew # https://github.com/shshemi/tabiew
    fx # https://fx.wtf/

    # system tools
    pciutils # lspci
    keychain # https://www.funtoo.org/Funtoo:Keychain
    trippy # https://trippy.cli.rs/
    cyme # https://github.com/tuna-f1sh/cyme

    # terminal recording
    asciinema # https://asciinema.org/
    asciinema-agg # https://github.com/asciinema/agg

    # software development
    lazygit
    git-cliff # https://git-cliff.org/
    tig # https://jonas.github.io/tig/
    gitui # https://github.com/extrawurst/gitui
    gh # https://cli.github.com/
    gh-dash # https://github.com/dlvhdr/gh-dash
    httpie
    jq # https://jqlang.github.io/jq/
    jqp # https://github.com/noahgorstein/jqp
    jql # https://github.com/yamafaktory/jql
    yq-go # https://mikefarah.gitbook.io/yq/
    fastgron # https://github.com/adamritter/fastgron
    fx # https://fx.wtf/
    ast-grep # https://ast-grep.github.io/
    difftastic # https://difftastic.wilfred.me.uk/
    tokei # https://github.com/XAMPPRocky/tokei
    amber # https://github.com/dalance/amber
    difftastic # https://github.com/Wilfred/difftastic
    exercism # https://exercism.org/
    diffsitter # https://github.com/afnanenayet/diffsitter
    universal-ctags # https://ctags.io/

    # database
    gobang # https://github.com/TaKO8Ki/gobang
    # rainfrog # https://github.com/achristmascarl/rainfrog

    # pdf
    pandoc # https://pandoc.org/
    groff # https://www.gnu.org/software/groff/
    ghostscript
    typst # https://github.com/typst/typst

    # nix tools
    nix-output-monitor # https://github.com/maralorn/nix-output-monitor
    nixd # nix lsp
    alejandra # code formatter
    nix-search-cli # https://github.com/peterldowns/nix-search-cli
    
    # llms
    ollama

    # just for nvim
    go
    nodejs_22

    # small terminal tools
    # https://github.com/maraloon/timer-tui
  ];
}
