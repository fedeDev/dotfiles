# Personal Configuration and Useful Tools

There are some subtrees to manage external repositories (e.g., st and zim).
Remember to update changes in upstream regulary using
```
git subtree pull --prefix=terminal/.local/st st_remote master --squash
git subtree pull --prefix=zsh/.zim zim_remote master --squash
```

Setup (assuming ubuntu-based distro):
```bash
sudo apt install git
git clone <repo> ~/dotfiles
cd ~/dotfiles
stow <each folder>
```
Compile st and register it with ```tic -s st.info```.

Dependencies
```
0. Prerequisites
  * devtools:
1. General
  * imagemagick
  * xprop
  * xdpyinfo
  * pstree
  * awk
  * pigz and pbzip2
  * ranger (https://github.com/ranger/ranger) TODO: check https://github.com/ranger/ranger/blob/master/ranger/config/rc.conf et al.
  * w3mimgdisplay (to view images inside ranger)
  * highlight (to pygmetnize inside rangera
  * ls++ (https://github.com/trapd00r/ls--) / check progress of https://github.com/ogham/exa/pull/253
  * zathura (with libsynctex!)
  * joe (gitignore generator)
2. neovim
  * nvim
  * ripgrep (https://github.com/BurntSushi/ripgrep)
  * fd (https://github.com/sharkdp/fd)
  * xclip
3. i3, desktop
  * install a recent enough version
  * j4-demnu-desktop [github](https://github.com/enkore/j4-dmenu-desktop), perhaps take a look at jaagr/polybar
  * TODO: try to make it nord: https://github.com/devdevdevdevdeo/dotfiles
  * TODO: check out Arc-Dark gtk theme
4. tmux
  * install tmux > ~2.7
  * git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
5. git
  * https://github.com/so-fancy/diff-so-fancy
6. terminal 
  * !!! compile terminal in ~/.local/st
  * fira code font (make sure it has support for powerline)
```
