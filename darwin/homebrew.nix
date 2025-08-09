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

  brews = [ 
    "mas" 
    "cocoapods" 
    "simtool" # https://github.com/azizuysal/simtool
  ];
  casks = [
    "db-browser-for-sqlite"
    # "xcodes"
    "hammerspoon"
    "element"
    "bruno" # https://www.usebruno.com
    "devtoys" # https://github.com/ObuchiYuki/DevToysMac
    "lapce" # https://lapce.dev/
    "zed" # https://zed.dev/
    "obs" # https://obsproject.com/
    "rio" # https://raphamorim.io/rio/
    "karabiner-elements" # https://karabiner-elements.pqrs.org/
    "yaak" # https://yaak.app/
    "container-use"
    # "simtool" # https://github.com/azizuysal/simtool
    #"lume" # https://github.com/trycua/lume, vm on macos
    #"google-chrome"
    #"firefox"
    #"obsidian"
    #"netnewswire"
    #"vlc"
    #"lastpass"
    #"discord"
  ];
  taps = [
    "azizuysal/simtool" 
  ];
}
