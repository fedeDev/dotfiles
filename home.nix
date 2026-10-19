{
  config,
  lib,
  pkgs,
  hunk,
  worktrunk,
  user,
  ...
}:

let
  releasedTargets = (import ./migration.nix).releasedTargets;
  ownsShell = !(builtins.elem ".zshrc" releasedTargets);
  ownsGit = !(builtins.elem ".config/git/home-manager.gitconfig" releasedTargets);
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  mocha = {
    rosewater = "#f5e0dc";
    flamingo = "#f2cdcd";
    pink = "#f5c2e7";
    mauve = "#cba6f7";
    red = "#f38ba8";
    maroon = "#eba0ac";
    peach = "#fab387";
    yellow = "#f9e2af";
    green = "#a6e3a1";
    teal = "#94e2d5";
    sky = "#89dceb";
    sapphire = "#74c7ec";
    blue = "#89b4fa";
    lavender = "#b4befe";
    text = "#cdd6f4";
    subtext1 = "#bac2de";
    subtext0 = "#a6adc8";
    overlay2 = "#9399b2";
    overlay1 = "#7f849c";
    overlay0 = "#6c7086";
    surface2 = "#585b70";
    surface1 = "#45475a";
    surface0 = "#313244";
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
  };
  mdterm = pkgs.writeShellScriptBin "mdterm" ''
    exec ${lib.getExe pkgs.glow} "$@"
  '';
  # Git's primary global config must remain writable for machine-local tooling
  # such as ac-sign. Home Manager owns this portable include instead.
  writableGitConfigSeed = pkgs.writeText "gitconfig-local-seed" ''
    [include]
      path = ~/.config/git/home-manager.gitconfig
  '';
in
{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  # nix-darwin's system PATH (/etc/zshrc) doesn't include Homebrew's prefix
  # since homebrew.enable is off (employer-managed Homebrew, see README).
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  home.packages = with pkgs; [
    antidote
    bat
    btop
    cmake
    cmake-format
    clang-tools
    delta
    diffnav
    difftastic
    eza
    fd
    fzf
    gh
    glow
    lazygit
    mdterm
    neovim
    nerd-fonts.fira-code
    ninja
    nixfmt
    nodejs
    (python3.withPackages (
      pythonPackages: with pythonPackages; [
        beautifulsoup4
        lxml
      ]
    ))
    python3Packages.pylatexenc
    ripgrep
    scc
    stylua
    tealdeer
    tree-sitter
    hunk.packages.${pkgs.stdenv.hostPlatform.system}.default
    imagemagick
    worktrunk.packages.${pkgs.stdenv.hostPlatform.system}.default
    yazi
    zoxide
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    BAT_THEME = "Catppuccin Mocha";
    EDITOR = "nvim";
    FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
    FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--color=bg:${mocha.base},bg+:${mocha.surface0},fg:${mocha.text},fg+:${mocha.text}"
      "--color=hl:${mocha.mauve},hl+:${mocha.mauve},info:${mocha.yellow},prompt:${mocha.blue}"
      "--color=pointer:${mocha.peach},marker:${mocha.green},spinner:${mocha.rosewater},header:${mocha.subtext0}"
      "--bind=ctrl-n:down,ctrl-p:up,alt-j:down,alt-k:up,tab:accept"
    ];
  };

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = ownsShell;
    enableCompletion = true;
    completionInit = ''
      autoload -Uz compinit
      zcompdump="${config.home.homeDirectory}/.cache/zsh/zcompdump-$ZSH_VERSION"
      if [[ -r "$zcompdump" ]]; then
        compinit -C -d "$zcompdump"
      else
        compinit -d "$zcompdump"
      fi
      unset zcompdump
    '';
    autocd = true;

    history = {
      size = 1000000;
      save = 1000000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-completions"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-history-substring-search"
        "Aloxaf/fzf-tab"
      ];
    };

    initContent = lib.mkMerge [
      ''
        setopt append_history
        setopt extended_history
        setopt hist_expire_dups_first
        setopt hist_find_no_dups
        setopt hist_ignore_all_dups
        setopt hist_ignore_dups
        setopt hist_ignore_space
        setopt hist_reduce_blanks
        setopt hist_save_no_dups
        setopt inc_append_history
        setopt share_history

        # Vi mode: Esc or Ctrl-[ (same keystroke, ASCII 0x1B) enters normal
        # mode for editing the command line. KEYTIMEOUT lowers the default
        # escape-sequence wait (in hundredths of a second) so switching modes
        # feels instant rather than laggy.
        bindkey -v
        KEYTIMEOUT=1

        bindkey '^f' autosuggest-accept
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        # Option/Alt-j and -k arrive as Esc+j and Esc+k. Bind them to the
        # exact same widgets as Down and Up in both vi keymaps.
        bindkey -M viins '^[j' history-substring-search-down
        bindkey -M viins '^[k' history-substring-search-up
        bindkey -M vicmd '^[j' history-substring-search-down
        bindkey -M vicmd '^[k' history-substring-search-up
        # Insert the previous command's last argument. Repeating Option-. walks
        # backward through older commands, matching the standard shell behavior.
        bindkey -M viins '^[.' insert-last-word
        bindkey -M vicmd '^[.' insert-last-word

        nuke() {
          print -Pn "%F{yellow}⚠️  WARNING: This will permanently delete all contents inside: %F{cyan}%d%f\n"
          read -q "reply?Are you absolutely sure you want to proceed? (y/N): "
          echo "" # Move to a new line after pressing a key

          if [[ "$reply" =~ ^[Yy]$ ]]; then
            # Nuke all files and hidden files, ignoring warnings for . and ..
            rm -rf ./* ./.* 2>/dev/null
            print -Pn "%F{green}✨ Build directory successfully wiped clean!%f\n"
          else
            print -Pn "%F{red}❌ Operation cancelled.%f\n"
          fi
        }

        # GitHub-flow smart log: compare the current HEAD with the long-lived
        # master line, regardless of the feature branch's upstream. A nested
        # experiment branch is already part of HEAD's ancestry, so its full path
        # back toward master appears naturally. The symmetric range shows work
        # on both sides and --boundary adds their merge base when reached.
        gsl() {
          local base="$1"

          if [[ -z "$base" ]]; then
            if git rev-parse --verify --quiet "origin/master^{commit}" >/dev/null; then
              base=origin/master
            elif git rev-parse --verify --quiet "master^{commit}" >/dev/null; then
              base=master
            fi
          fi

          if [[ -z "$base" ]]; then
            print -u2 "gsl: master not found; fetch it or use gsl <master-ref>"
            return 1
          fi

          git log --graph --decorate --oneline --left-right --boundary \
            --topo-order --max-count=16 "$base...HEAD"
        }

        # Cursor shape follows vi mode, matching vim itself: bar while
        # inserting text, block in normal mode. DECSCUSR escape sequences.
        function zle-keymap-select {
          if [[ $KEYMAP == vicmd ]]; then
            printf '\e[2 q'
          else
            printf '\e[6 q'
          fi
        }
        zle -N zle-keymap-select
        function zle-line-init {
          printf '\e[6 q'
        }
        zle -N zle-line-init

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' menu select
        zstyle ':fzf-tab:*' fzf-command fzf
        zstyle ':fzf-tab:*' fzf-bindings 'ctrl-n:down' 'ctrl-p:up' 'alt-j:down' 'alt-k:up' 'tab:accept'
        zstyle ':fzf-tab:*' switch-group ',' '.'

        # herdr is Homebrew-managed (not nix-managed, see README), so guard
        # against it being absent on a fresh machine before first `brew install`.
        command -v herdr >/dev/null 2>&1 && eval "$(herdr completion zsh)"

        # SSHFS turns prompt Git discovery and eza's per-entry metadata queries
        # into network round trips. Use a filesystem-only prompt and BSD ls while
        # inside either GPFS mount, restoring the normal tools on the way out.
        # :A resolves symlinks, including /gpfs -> ~/gpfs -> ~/ci-gpfs.
        autoload -Uz add-zsh-hook
        _set_gpfs_shell_mode() {
          case "''${PWD:A}/" in
            "$HOME/ci-gpfs/"*|"$HOME/qs-gpfs/"*)
              export STARSHIP_CONFIG="$HOME/.config/starship-gpfs.toml"
              alias ls='command ls'
              alias ll='command ls -la'
              ;;
            *)
              unset STARSHIP_CONFIG
              alias ls='eza --icons=auto'
              alias ll='eza -lah --git --icons=auto'
              ;;
          esac
        }
        add-zsh-hook chpwd _set_gpfs_shell_mode

        # Writable, machine-local additions and secrets. Keep this file outside
        # Home Manager so its contents never enter Git or the Nix store.
        [[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

      ''
      (lib.mkOrder 2000 ''
        # Home Manager writes static aliases after the main init block; apply
        # the current directory's GPFS overrides once those aliases exist.
        _set_gpfs_shell_mode

        # Zoxide's doctor expects its precmd/chpwd hooks to be installed last.
        # Keep it interactive-only: agent subprocesses can source .zshrc without
        # a prompt loop, which otherwise produces a false doctor warning.
        if [[ $- == *i* ]]; then
          eval "$(${lib.getExe pkgs.zoxide} init zsh --cmd cd)"
        fi
      '')
    ];

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      cat = "bat";
      claude = "claude --allow-dangerously-skip-permissions";
      diff = "difft";
      g = "git";
      gfm = "git fetch origin master:refs/remotes/origin/master";
      gits = "git status --short --branch";
      lg = "lazygit";
      ll = "eza -lah --git --icons=auto";
      ls = "eza --icons=auto";
      md = "mdterm";
      tree = "eza --tree --icons=auto";
    };
  };

  programs.starship = {
    enable = ownsShell;
    settings = {
      add_newline = false;
      palette = "catppuccin_mocha";
      format = "\${custom.worktree}$directory$git_branch$git_status$cmd_duration$line_break$character";

      character = {
        success_symbol = "[>](mauve)";
        error_symbol = "[>](red)";
      };

      directory = {
        style = "bold blue";
        truncation_length = 4;
        truncate_to_repo = false;
      };

      # Linked worktrees keep a `commondir` file in their per-worktree Git
      # directory; the primary checkout does not. Make that distinction loud
      # even when the directory module has shortened the checkout path.
      custom.worktree = {
        command = "printf wt";
        when = ''git_dir=$(git rev-parse --git-dir 2>/dev/null) && test -f "$git_dir/commondir"'';
        require_repo = true;
        shell = [ "sh" ];
        format = "[$output]($style) ";
        style = "bold yellow";
        description = "linked Git worktree marker";
      };

      git_branch.style = "mauve";
      git_status.style = "peach";
      cmd_duration = {
        min_time = 500;
        format = "[$duration]($style) ";
        style = "yellow";
      };

      palettes.catppuccin_mocha = {
        rosewater = mocha.rosewater;
        flamingo = mocha.flamingo;
        pink = mocha.pink;
        mauve = mocha.mauve;
        red = mocha.red;
        maroon = mocha.maroon;
        peach = mocha.peach;
        yellow = mocha.yellow;
        green = mocha.green;
        teal = mocha.teal;
        sky = mocha.sky;
        sapphire = mocha.sapphire;
        blue = mocha.blue;
        lavender = mocha.lavender;
        text = mocha.text;
        subtext1 = mocha.subtext1;
        subtext0 = mocha.subtext0;
        overlay2 = mocha.overlay2;
        overlay1 = mocha.overlay1;
        overlay0 = mocha.overlay0;
        surface2 = mocha.surface2;
        surface1 = mocha.surface1;
        surface0 = mocha.surface0;
        base = mocha.base;
        mantle = mocha.mantle;
        crust = mocha.crust;
      };
    };
  };

  programs.zoxide = {
    enable = ownsShell;
    enableZshIntegration = false; # initialized last in programs.zsh.initContent
    options = [ "--cmd cd" ];
  };

  programs.fzf = {
    enable = ownsShell;
    enableZshIntegration = true;
  };

  programs.tealdeer = {
    enable = ownsShell;
    settings.updates.auto_update = true;
  };

  home.file = lib.filterAttrs (name: _: !(builtins.elem name releasedTargets)) {
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
    ".config/lazygit".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/lazygit";
    ".config/gh-dash/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/gh-dash/config.yml";
    ".config/diffnav/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/diffnav/config.yml";
    # macOS Lazygit prefers this native path when an existing config is present.
    # Link only config.yml so Lazygit's writable state.yml stays unmanaged.
    "Library/Application Support/lazygit/config.yml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/lazygit/config.yml";
    ".config/btop".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/btop";
    ".config/bat".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/bat";
    ".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/yazi";
    ".config/herdr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/config.toml";
    ".config/herdr/plugins/config/jhochenbaum.hunkdiff/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/hunkdiff.toml";
    ".config/hunk".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/hunk";
    ".config/worktrunk".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/worktrunk";
    ".config/dev".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/dev";
    ".config/starship-gpfs.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/starship-gpfs.toml";
    # Keep portable Git behavior declarative without making the primary config
    # immutable. The writable config includes this file, then tools like
    # ac-sign may safely append machine-specific settings to the primary file.
    ".config/git/home-manager.gitconfig".text = ''
      [core]
        pager = delta

      [delta]
        features = catppuccin-mocha
        navigate = true
        side-by-side = true

      [delta "catppuccin-mocha"]
        dark = true
        syntax-theme = Catppuccin Mocha
        plus-style = syntax "#2b4738"
        minus-style = syntax "#4a2b35"
        plus-emph-style = syntax "#365942"
        minus-emph-style = syntax "#613442"
        hunk-header-style = file line-number syntax
        file-style = bold "#89b4fa"
        file-decoration-style = "#585b70"
        hunk-header-decoration-style = "#585b70"
        line-numbers = true
        line-numbers-left-style = "#6c7086"
        line-numbers-right-style = "#6c7086"
        line-numbers-minus-style = "#f38ba8"
        line-numbers-plus-style = "#a6e3a1"

      [diff]
        tool = difftastic

      [difftool "difftastic"]
        cmd = difft "$LOCAL" "$REMOTE"

      [interactive]
        diffFilter = delta --color-only

      [merge]
        conflictstyle = zdiff3

      [pager]
        blame = delta
        # Diffnav adds file-tree navigation while using Delta for rendering.
        diff = diffnav
        difftool = true
        log = delta
        show = delta

      [pull]
        ff = only
    '';
    # Keep Git's global ignore inside the Home Manager generation rather than
    # symlinking it into this checkout.  The checkout currently lives under
    # macOS's TCC-protected Downloads directory, which makes Git fail when run
    # by terminals that do not have Downloads access.
    ".config/git/ignore".text = ''
      .claude/
    '';
  };

  home.activation.buildBatCache = lib.mkIf (!(builtins.elem ".config/bat" releasedTargets)) (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      ${pkgs.bat}/bin/bat cache --build >/dev/null 2>&1 || true
    ''
  );

  # `programs.git` normally links ~/.config/git/config into /nix/store. That is
  # correct for purely declarative setups, but libgit2-based setup tools try to
  # lock and update that exact file. Replace only Home Manager's old symlink,
  # seed a writable front config once, and never overwrite it on later rebuilds.
  # Machine-local tools remain optional and Home Manager never invokes them.
  home.activation.bootstrapWritableGitConfig = lib.mkIf ownsGit (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      git_config="$HOME/.config/git/config"
      if [ -L "$git_config" ]; then
        case "$(${pkgs.coreutils}/bin/readlink "$git_config")" in
          /nix/store/*-home-manager-files/.config/git/config)
            rm "$git_config"
            ;;
        esac
      fi
      if [ ! -e "$git_config" ]; then
        mkdir -p "$HOME/.config/git"
        ${pkgs.coreutils}/bin/install -m 0600 ${writableGitConfigSeed} "$git_config"
      fi
    ''
  );

}
