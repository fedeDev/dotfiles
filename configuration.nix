{ user, ... }:

{
  # Determinate Nix manages the daemon.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = user;
  users.users.${user}.home = "/Users/${user}";
  system.stateVersion = 6;

  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      _HIHideMenuBar = true;
    };

    dock = {
      autohide = false;
      show-recents = false;
      tilesize = 40;
    };

    finder = {
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad.Clicking = true;
  };

  nix-homebrew = {
    enable = true;
    autoMigrate = true;
    enableZshIntegration = false;
    inherit user;

    trust.formulae = [
      "can1357/tap/omp"
    ];
  };

  homebrew = {
    enable = true;

    taps = [
      "can1357/tap"
    ];

    brews = [
      "herdr"
      "omp"
    ];

    casks = [
      "ghostty"
    ];

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # cleanup = "zap";
      cleanup = "none";
      extraEnv = {
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
        HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
      };
    };
  };

  programs.zsh = {
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
  };
}
