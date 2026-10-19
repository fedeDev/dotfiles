# Release one group at a time, then USER runs ./rebuild.sh.
# Phase 3, group 1 prepared; no live release occurs until the rebuild.
{
  releasedTargets = [
    ".config/bat"
    ".config/btop"
    ".config/diffnav/config.yml"
    ".config/gh-dash/config.yml"
  ];
}
