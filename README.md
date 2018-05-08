# Personal Configuration and Useful Tools

There are some subtrees to manage external repositories (e.g., st and zim).
Remember to update changes in upstream regulary using
```
git subtree pull --prefix <name-of-remote-do:git remote> master --squash
```

Setup (assuming ubuntu-based distro):
```bash
sudo apt install git
git clone <repo> ~/dotfiles
cd ~/dotfiles
stow <each folder>
```
profit!

Dependencies
```
1. General
  * imagemagick
  * xprop
  * xdpyinfo
  * pstree
  * awk
2. i3, desktop
  * j4-demnu-desktop [github](https://github.com/enkore/j4-dmenu-desktop), perhaps take a look at jaagr/polybar
  * TODO: try to make it nord: https://github.com/devdevdevdevdeo/dotfiles
  * TODO: check out Arc-Dark gtk theme
3. tmux
  * git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
