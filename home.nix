{
  allowed-unfree-packages,
  lib,
  inputs,
  pkgs,
  ...
}: let
  source = pkgs.fetchurl {
    url = "https://github.com/rvcas/room/releases/latest/download/room.wasm";
    sha256 = "15xx83yyjb79xr68mwb3cbw5rwm62ryczc0vv1vcpjzsd1visadj";
  };

  # Undo this version lock after closing out of all sessions
  pkgs_0_39_2 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/e89cf1c932006531f454de7d652163a9a5c86668.tar.gz";
  }) {};

  default_pkgs = with pkgs; [
    # cool rust rewrites of posix tools
    sd # sed
    fd # find
    procs # ps
    dust # du
    tokei
    hyperfine
    bandwhich
    grex
    bat-extras.batgrep
    nushell

    dig
    btop
    inetutils
    mongosh
    gohufont
    k9s
    git
    font-awesome
    powerline-fonts
    powerline-symbols
    nerdfonts
    (python311.withPackages (ps:
      with ps; [
        python-lsp-server
        python-lsp-ruff
        python-lsp-black
        pylsp-rope
        pylsp-mypy
        pyls-isort
      ]))

    nil
    entr
    kubectl
    # awscli
    kubernetes-helm
    helmfile
    terraform
    ansible
    inputs.neovim-flake.packages.${pkgs.system}.default
    devenv
    pkg-config
    openssl
    istioctl
    nmap
    go
  ];

  linux_pkgs = with pkgs; [
    clang
    clang-tools
    cmake
    llvm
    gnumake
    docker
    docker-compose
  ];

  shellAliases = {
    l = "lsd -alF";
    c = "cd";
    e = "nvim";
    gcm = "git commit -m";
    se = "sudoedit";
    sz = "source ~/.zshrc";
    tg = "batgrep";
    conf = "sudoedit /etc/nixos/configuration.nix";
    sshdemo = "ssh -i ~/repos/platform/k8s/keys/ahq.demo admin@a.demo.analyticshq.com";
    sshdev = "ssh -i ~/repos/platform/k8s/keys/ahq.dev admin@a.dev.analyticshq.com";
    update = "sudo nixos-rebuild switch --flake ~/repos/nutanix-dev-flake#nuvm --impure";
  };
in {
  # nixpkgs.config = {
  #   allowUnfree = true;
  # };
  # nixpkgs.config = {
  #   allowUnfree = true;
  #   allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowed-unfree-packages;
  # };
  home.sessionVariables = {
    EDITOR = "nvim";
    KUBE_EDITOR = "nvim";
  };
  home.shellAliases = shellAliases;
  home.packages =
    if pkgs.system == "x86_64-linux"
    then linux_pkgs ++ default_pkgs
    else default_pkgs;
  fonts.fontconfig.enable = true;

  programs = {
    ripgrep.enable = true;
    bat.enable = true;
    tealdeer.enable = true;

    autojump.enable = true;
    jq.enable = true;
    nix-index.enable = true;
  };

  programs.helix = {
    enable = true;
    defaultEditor = false;
    settings = {
      theme = "gruvbox";
      editor.line-number = "relative";
      editor.cursor-shape.insert = "bar";
      editor.lsp.enable = true;
      editor.lsp.display-messages = true;
    };
  };

  programs.direnv = {
    enable = true;
    config = {
      whitelist.prefix = ["~/repos/kubezt"];
      hide_env_diff = true;
    };
  };

  programs.git = {
    enable = true;
    userName = "kevinlmadison";
    userEmail = "coolklm121@gmail.com";
    delta = {
      enable = true;
      options = {
        syntax-theme = "gruvbox-dark";
        dark = true;
        line-numbers = true;
        side-by-side = true;
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.lsd = {
    enable = true;
    settings = {
      icons.when = "auto";
      icons.theme = "fancy";
      date = "relative";
      ignore-globs = [
        ".git"
        ".hg"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    sessionVariables = {
      EDITOR = "nvim";
      KUBE_EDITOR = "nvim";
      TERM = "xterm-256color";
    };
    autocd = true;
    history = {
      save = 10000;
      path =
        if pkgs.system == "aarch64-darwin"
        then "/Users/kubezt/.histfile"
        else "/home/kubezt/.histfile";
    };
    initExtra =
      if pkgs.system == "aarch64-darwin"
      then ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      ''
      else "";
    oh-my-zsh = {
      enable = true;
      plugins = [
        "z"
        "git"
        "sudo"
        "docker"
        "kubectl"
        "vi-mode"
        "ssh-agent"
      ];
      theme = "robbyrussell";
    };
  };

  manual.manpages.enable = true;
  home.username = "kubezt";
  home.homeDirectory = "/home/kubezt";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  programs.home-manager.enable = true;
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    settings = {
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };
      aws = {
        symbol = " ";
      };
    };
  };

  home.file.".config/zellij/plugins/room.wasm".source = source;

  programs.zellij = {
    enable = true;
    # package = pkgs_0_39_2.zellij;
    settings = {
      keybinds = {
        normal = builtins.listToAttrs (lib.genList (n: {
            name = "bind \"Alt ${toString (n + 1)}\"";
            value = {
              GoToTab = n + 1;
              SwitchToMode = "Normal";
            };
          })
          9);
        shared_except = {
          _args = ["locked"];
          "bind \"Ctrl y\"" = {
            LaunchOrFocusPlugin = {
              _args = ["file:~/.config/zellij/plugins/room.wasm"];
              floating = true;
              ignore_case = true;
            };
          };
          "bind \"Alt f\"" = {
            LaunchPlugin = {
              _args = ["zellij:filepicker"];
              close_on_selection = true;
            };
          };
        };
      };
      default_layout = "compact";
      default_shell = "/etc/profiles/per-user/kubezt/bin/zsh";
      pane_frames = true;
      simplified_ui = true;
      copy_clipboard = "system";
      copy_on_select = true;
      # copy_command = "xclip -selection clipboard";
      # layout_dir = "~/.config/zellij/layouts";
      theme = "rose-pine";
      # if pkgs.system == "aarch64-darwin"
      # then "gruvbox-dark"
      # else "dracula";
      # https://github.com/nix-community/home-manager/issues/3854
      themes.rose-pine = {
        fg = [224 223 244]; # e0def4
        bg = [25 23 36]; # 191724
        black = [0 0 0]; # 000000
        red = [235 111 146]; # eb6f92
        green = [49 116 143]; # 31748f
        yellow = [246 193 119]; # f6c177
        blue = [156 207 216]; # 9ccfd8
        magenta = [196 167 231]; # c4a7e7
        cyan = [235 188 186]; # ebbcba
        white = [224 223 244]; # e0def4
        orange = [234 154 151]; # #ea9a97
      };
    };
  };
}
