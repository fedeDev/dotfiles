{
  config,
  lib,
  pkgs,
  user,
  ...
}:

let
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
in
{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    antidote
    bat
    btop
    delta
    difftastic
    eza
    fd
    fzf
    gh
    git
    glow
    lazygit
    mdterm
    neovim
    nerd-fonts.jetbrains-mono
    python3Packages.pylatexenc
    ripgrep
    scc
    tealdeer
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
    ];
  };

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
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

    initContent = ''
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

      bindkey '^f' autosuggest-accept
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' switch-group ',' '.'

      if command -v omp >/dev/null 2>&1; then
        eval "$(omp completions zsh)"
      fi
    '';

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      cat = "bat";
      diff = "difft";
      g = "git";
      lg = "lazygit";
      ll = "eza -lah --git --icons=auto";
      ls = "eza --icons=auto";
      md = "mdterm";
      tree = "eza --tree --icons=auto";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      palette = "catppuccin_mocha";
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";

      character = {
        success_symbol = "[>](mauve)";
        error_symbol = "[>](red)";
      };

      directory = {
        style = "bold blue";
        truncation_length = 4;
        truncate_to_repo = false;
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
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      core.pager = "delta";
      diff.tool = "difftastic";
      difftool.difftastic.cmd = "difft \"$LOCAL\" \"$REMOTE\"";
      include.path = "~/.config/git/catppuccin-delta.gitconfig";
      merge.conflictstyle = "zdiff3";
      pager.difftool = true;
      pull.ff = "only";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "catppuccin-mocha";
      navigate = true;
      side-by-side = true;
    };
  };

  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };

  home.file = {
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
    ".config/lazygit".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/lazygit";
    ".config/btop".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/btop";
    ".config/bat".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/bat";
    ".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/yazi";
    ".config/git/catppuccin-delta.gitconfig".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/git/catppuccin-delta.gitconfig";
  };

  home.activation.buildBatCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.bat}/bin/bat cache --build >/dev/null 2>&1 || true
  '';
}
