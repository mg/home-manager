{
  enable = true;
  caskArgs.no_quarantine = true;
  global.brewfile = true;
  /*masApps = {
    "LimeChat" = 414030210;
    "Pastebot" = 1179623856;
    "Ivory" = 2145332318;
    "Apple Developer" = 640199958;
    "TestFlight" = 899247664;
    "Transporter" = 1450874784;
  };*/
  brews = [ "mas" ];
  casks = [ 
    "db-browser-for-sqlite" 
    "alacritty" 
    "kitty" 
    "wezterm" # https://wezfurlong.org/wezterm/index.html
    "xcodes" 
    "hammerspoon" 
    "element"
    #"google-chrome"
    #"firefox"
    #"visual-studio-code"
    #"obsidian"
    #"netnewswire"
    #"vlc"
    #"lastpass"
    #"discord"
  ];
}