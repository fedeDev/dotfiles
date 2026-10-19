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

  # Homebrew is the employer-managed installation at /opt/homebrew.
  # Keep it entirely outside nix-darwin; the flake does not import nix-homebrew.
  homebrew.enable = false;

  programs.zsh = {
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
  };
}
