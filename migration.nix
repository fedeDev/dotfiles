# Release one group at a time, then USER runs ./rebuild.sh.
# Phase 3: groups 1-5 applied; final shell group staged for the user rebuild.
{
  releasedTargets = [
    ".config/bat"
    ".config/btop"
    ".config/diffnav/config.yml"
    ".config/gh-dash/config.yml"
    ".config/yazi"
    ".config/lazygit"
    "Library/Application Support/lazygit/config.yml"
    ".config/hunk"
    ".config/herdr/config.toml"
    ".config/herdr/plugins/config/jhochenbaum.hunkdiff/config.toml"
    ".config/worktrunk"
    ".config/ghostty"
    ".config/nvim"
    ".config/git/home-manager.gitconfig"
    ".config/git/ignore"
    ".zshrc"
    ".config/starship-gpfs.toml"
    ".config/dev"
  ];
}
