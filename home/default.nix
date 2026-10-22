{ config, lib, pkgs, aster, tpm-src, ... }:

let
  # Home packages do not run development-shell setup hooks. Give the default
  # macOS compiler explicit iconv paths without affecting project compilers.
  defaultClang = pkgs.clang.override (lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    nixSupport = {
      cc-cflags = "-isystem ${lib.getDev pkgs.libiconv}/include";
      cc-ldflags = "-L${lib.getLib pkgs.libiconv}/lib";
    };
  });
in
{
  imports = [ ./lorri.nix ];

  options.dots.checkoutPath = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/dots";
    description = "Absolute checkout path for the writable Neovim configuration.";
  };

  config = {
    # This controls Home Manager compatibility defaults, not package versions.
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
    xdg.enable = true;
    # Used to validate user settings; this does not replace the system daemon.
    nix.package = pkgs.nix;
    nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

    home.packages = with pkgs; [
      git curl wget jq
      tmux ripgrep fd fzf eza lazygit starship zoxide zsh-autosuggestions
      python3 python3Packages.pip lua luarocks luaPackages.luacheck
      # Clang already has priority 10; lowPrio GCC would also be 10 and collide.
      defaultClang clang-tools (lib.setPrio 20 gcc) libiconv gnumake cmake unzip
      go (rust-bin.stable."1.99.0".default) jdk nodejs_22
      eslint eslint_d pyright prettier typescript typescript-language-server
      vscode-langservers-extracted lua-language-server gopls rust-analyzer stylua
      aster
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      xsel wl-clipboard
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      JAVA_HOME = pkgs.jdk.home;
    };

    programs.zsh = {
      enable = true;
      dotDir = config.home.homeDirectory;
      # Keep the existing selective Oh My Zsh loader and completion setup.
      enableCompletion = false;
      initContent = lib.mkOrder 1000 ''
        export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
        export DOTS_ZSH_SYNTAX_HIGHLIGHTING=${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source ${../.zshrc}
      '';
    };

    programs.neovim = {
      enable = true;
      withPython3 = true;
      withNodeJs = true;
      # No Nix-managed plugins: lazy.nvim and Mason retain ownership.
    };

    home.activation.checkDotsCheckout = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      if [[ ${lib.escapeShellArg config.xdg.configHome} -ef ${lib.escapeShellArg "${config.dots.checkoutPath}/.config"} ]]; then
        echo 'Refusing activation: the XDG config directory points into this dotfiles checkout.' >&2
        echo 'Separate the home config directory from the checkout before switching; keep the source files.' >&2
        exit 1
      fi
      if [[ ! -f ${lib.escapeShellArg "${config.dots.checkoutPath}/.config/nvim/init.lua"} ]]; then
        echo 'Neovim checkout missing. Set dots.checkoutPath to this repository.' >&2
        exit 1
      fi
    '';

    home.file = {
      ".clang-format".source = ../.clang-format;
      ".vimrc".source = ../.vimrc;
      ".p10k.zsh".source = ../.p10k.zsh;
      ".tmux.conf".source = ../.tmux.conf;
      ".tmux.conf.local".source = ../.tmux.conf.local;
      ".tmux.conf.remote".source = ../.tmux.conf.remote;
      # TPM still installs the plugins selected by the existing tmux configs.
      ".tmux/plugins/tpm".source = tpm-src;
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      # Configuration only: existing macOS services remain outside this setup.
      ".yabairc".source = ../.yabairc;
      ".skhdrc".source = ../.skhdrc;
    };

    xdg.configFile = {
      # lazy.nvim writes lazy-lock.json here. Plugins stay in Neovim's data dir.
      "nvim".source = config.lib.file.mkOutOfStoreSymlink
        "${config.dots.checkoutPath}/.config/nvim";
      "aster".source = ../.config/aster;
      "kitty".source = ../.config/kitty;
      "opencode".source = ../.config/opencode;
      "spotify-player".source = ../.config/spotify-player;
      "starship.toml".source = ../.config/starship.toml;
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      "sketchybar".source = ../.config/sketchybar;
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      "hypr".source = ../.config/hypr;
      "river".source = ../.config/river;
      "waybar".source = ../.config/waybar;
    };
  };
}
