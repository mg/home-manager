# https://github.com/rothgar/awesome-tuis
{pkgs, ...}: {
  home.packages = with pkgs; [
    nb
    zsh-forgit # https://github.com/wfxr/forgit, https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/shells/zsh/zsh-forgit/default.nix#L51
    zsh-fzf-history-search
    zsh-fzf-tab
    # intelli-shell # https://lasantosr.github.io/intelli-shell/index.html
    # envx # https://github.com/mikeleppane/envx  # cargo install envex
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

    uutils-coreutils-noprefix # https://github.com/uutils/coreutils

    # shells
    # xonsh # https://xon.sh/

    # task runners
    just 
    mask # https://github.com/jacobdeichert/mask

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
    eza # https://github.com/eza-community/ezhttps://github.com/ouch-org/oucha
    entr # https://eradman.com/entrproject/
    renameutils # https://www.nongnu.org/renameutils/
    rm-improved # https://github.com/nivekuil/rip
    fswatch # https://github.com/emcrisostomo/fswatch
    # fex # https://github.com/18alantom/fex
    pls # https://pls.cli.rs/
    television # https://github.com/alexpasmantier/television
    # superfile # https://superfile.netlify.app/
    (superfile.overrideAttrs (oldAttrs: {
      doCheck = false;
    }))
    # v1.3.2 
    serpl # https://github.com/yassinebridi/serpl

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

    # archives
    ouch # https://Sgithub.com/ouch-org/ouch

    # monitoring
    iftop # network monitoring
    bandwhich 
    gping
    # nping # https://github.com/hanshuaikang/Nping
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
    container # https://github.com/apple/container

    # process management
    pueue # https://github.com/Nukesor/pueue
    mprocs # https://github.com/pvolok/mprocs

    # disk tools
    duf
    du-dust
    ncdu # https://dev.yorhel.nl/ncdu

    # network tools
    doggo # https://doggo.mrkaran.dev/docs/
    # impala # https://github.com/pythops/impala

    # text tools
    neovim # https://neovim.io/
    neovim-remote # https://github.com/mhinz/neovim-remote
    # helix # https://helix-editor.com/
    evil-helix # https://github.com/usagi-flow/evil-helix
    sad # https://github.com/ms-jpq/sad
    gnused
    gawk
    xan

    # video & image tools
    gifski
    imagemagick

    # file viewers
    glow

    # log tools
    # 2025-03-02 removed
    # error fixed here https://github.com/NixOS/nixpkgs/pull/353457 but not out
    # tailspin # https://github.com/bensadeh/tailspin
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
    presenterm # https://github.com/mfontanini/presenterm

    # software development
    lazygit
    git-cliff # https://git-cliff.org/
    tig # https://jonas.github.io/tig/
    gitui # https://github.com/extrawurst/gitui
    gitu # https://github.com/altsem/gitu
    gh # https://cli.github.com/
    gh-dash # https://github.com/dlvhdr/gh-dash
    gmap # https://github.com/seeyebe/gmap
    act # https://nektosact.com/usage/index.html
    httpie
    xh # https://github.com/ducaale/xh
    jq # https://jqlang.github.io/jq/
    jqp # https://github.com/noahgorstein/jqp
    jql # https://github.com/yamafaktory/jql
    otree # https://github.com/fioncat/otree
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
    atac # https://atac.julien-cpsn.com/
    stylua # https://github.com/JohnnyMorganz/StyLua

    # database
    rainfrog # https://github.com/achristmascarl/rainfrog
    duckdb

    # disable because it is pulling in a borken python package (trouble-log.md#2025-07-17) 
    # harlequin # https://harlequin.sh/docs/getting-started/usage

    # pdf
    pandoc # https://pandoc.org/
    groff # https://www.gnu.org/software/groff/
    ghostscript
    typst # https://github.com/typst/typst
    ripgrep-all # https://github.com/phiresky/ripgrep-all

    # nix tools
    nix-output-monitor # https://github.com/maralorn/nix-output-monitor
    nixd # nix lsp
    alejandra # code formatter
    nix-search-cli # https://github.com/peterldowns/nix-search-cli
    nix-tree
    mcp-nixos # https://github.com/utensils/mcp-nixos
    # claude mcp add nixos --scope project mcp-nixos -> ~/.claude.json
    
    # llms
    # ollama
    # opencode
    # claude-code
    gemini-cli
    codex
    crush
    mcp-proxy

    # aider-chat-full
    # tmuxai # https://tmuxai.dev/

    # system wide runtimes and compilers 
    go
    nodejs_22
    bun
    uv
    cargo


    # small terminal tools
    # https://github.com/maraloon/timer-tui

    # global install of elixir 
    beam.packages.erlang_27.erlang
    beam.packages.erlang_27.elixir_1_18
  ];
}
