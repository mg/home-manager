# https://github.com/LnL7/nix-darwin
# https://daiderd.com/nix-darwin/manual/index.html
# https://dev.jmgilman.com/environment/tools/nix/nix-darwin/

{ pkgs, machineConfig, ... }: 
{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  #ssl-cert-file = /etc/ssl/certs/w00402.cer


  services.nix-daemon.enable = true;
  users.users.${machineConfig.username} = {
    name = machineConfig.username;
    home = machineConfig.home;
  };

  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [ nushell ];
    loginShell = pkgs.zsh;
  
    systemPackages = [ 
      pkgs.coreutils-full
    ];

    systemPath = [ "/opt/homebrew/bin" ];
    # pathsToLink = [ "/Applications" ];
  };

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [ 
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "Meslo" "FiraCode" "FiraMono" ]; }) 
  ];

  networking.computerName = machineConfig.hostname;
  networking.hostName = machineConfig.hostname;
  networking.localHostName = machineConfig.hostname;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults.finder ={ 
    ShowPathbar = true;
    ShowStatusBar = true;
    _FXShowPosixPathInTitle = true;
    FXEnableExtensionChangeWarning = false;
  };

  system.defaults.dock = {
    autohide = false;
    appswitcher-all-displays = true;
    expose-group-by-app = true;
    magnification = true;
    mru-spaces = false;
    orientation = "bottom";
    tilesize = 48;
    largesize = 64;

    # disable hot corners
    wvous-bl-corner = 1;
    wvous-tl-corner = 1;
    wvous-br-corner = 1;
    wvous-tr-corner = 1;
  };

  system.defaults.NSGlobalDomain = {
    AppleEnableMouseSwipeNavigateWithScrolls = false;
    AppleEnableSwipeNavigateWithScrolls = false;
    AppleMeasurementUnits = "Centimeters";
    AppleTemperatureUnit = "Celsius";
    AppleMetricUnits = 1;
    AppleICUForce24HourTime = true;
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSDocumentSaveNewDocumentsToCloud = false;
    "com.apple.keyboard.fnState" = true;
    "com.apple.trackpad.enableSecondaryClick" = false;
  };

  system.defaults = {
    loginwindow.GuestEnabled = false;
  };

  security.pam.enableSudoTouchIdAuth = true;

  homebrew = import ./homebrew.nix;

  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      # Add a context menu item for showing the Web Inspector in web views
      WebKitDeveloperExtras = true;
    };
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.screensaver" = {
      # Require password immediately after sleep or screen saver begins
      askForPassword = 1;
      askForPasswordDelay = 0;
    };
    /*"com.apple.screencapture" = {
      location = "~/Desktop";
      type = "png";
    };*/
    /*"com.apple.Safari" = {
      # Privacy: don’t send search queries to Apple
      UniversalSearchEnabled = false;
      SuppressSearchSuggestions = true;
      # Press Tab to highlight each item on a web page
      WebKitTabToLinksPreferenceKey = true;
      ShowFullURLInSmartSearchField = true;
      # Prevent Safari from opening ‘safe’ files automatically after downloading
      AutoOpenSafeDownloads = false;
      ShowFavoritesBar = false;
      IncludeInternalDebugMenu = true;
      IncludeDevelopMenu = true;
      WebKitDeveloperExtrasEnabledPreferenceKey = true;
      WebContinuousSpellCheckingEnabled = true;
      WebAutomaticSpellingCorrectionEnabled = false;
      AutoFillFromAddressBook = true;
      AutoFillCreditCardData = true;
      AutoFillMiscellaneousForms = true;
      WarnAboutFraudulentWebsites = true;
      WebKitJavaEnabled = true;
      WebKitJavaScriptCanOpenWindowsAutomatically = false;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = true;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = true;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
    };*/
    "com.apple.mail" = {
      # Disable inline attachments (just show the icons)
      # DisableInlineAttachmentViewing = true;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.print.PrintingPrefs" = {
      # Automatically quit printer app once the print jobs complete
      "Quit When Finished" = true;
    };
    /*"com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };*/
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Turn on app auto-update
    "com.apple.commerce".AutoUpdate = true;
  };

  # services.skhd.enable = true;
  /*
  services.yabai.enable = true;
  services.yabai.config = {
    # focus_follows_mouse = "autoraise";
    mouse_follows_focus = "off";
    window_placement    = "second_child";
    window_opacity      = "off";
    top_padding         = 36;
    bottom_padding      = 10;
    left_padding        = 10;
    right_padding       = 10;
    window_gap          = 10;
  };
  */

  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
