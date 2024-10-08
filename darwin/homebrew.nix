{
  enable = true;
  caskArgs.no_quarantine = true;
  global.brewfile = true;
  masApps = {
    # "Gifski" = 1351639930;
    /* "LimeChat" = 414030210;
    "Pastebot" = 1179623856;
    "Ivory" = 2145332318;
    "Apple Developer" = 640199958;
    "TestFlight" = 899247664;
    "Transporter" = 1450874784; */
  };

  brews = [ "mas" "cocoapods" ];
  casks = [
    "db-browser-for-sqlite"
    "alacritty"
    "kitty"
    "wezterm" # https://wezfurlong.org/wezterm/index.html
    "xcodes"
    "hammerspoon"
    "element"
    "bruno" # https://www.usebruno.com
    "devtoys" # https://github.com/ObuchiYuki/DevToysMac
    "lapce" # https://lapce.dev/
    "zed" # https://zed.dev/
    "neovide" # https://github.com/neovide/neovide
    "obs" # https://obsproject.com/
    "rio" # https://raphamorim.io/rio/
    "karabiner-elements" # https://karabiner-elements.pqrs.org/
    #"google-chrome"
    #"firefox"
    #"visual-studio-code"
    #"obsidian"
    #"netnewswire"
    #"vlc"
    #"lastpass"
    #"discord"
  ];
  taps = [
  ];
}
