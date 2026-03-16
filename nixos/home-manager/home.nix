{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprlock.nix
    ./hypridle.nix
    ./modules/dev-tools.nix
    ./modules/emacs.nix
    ./modules/graphics.nix
    ./modules/hyprland.nix
    ./modules/nvim.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "msantana";
  home.homeDirectory = "/home/msantana";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.hello

    # Browsers
    pkgs.google-chrome
    pkgs.chromium
    inputs.zen-browser.packages."${pkgs.system}".default

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    pkgs.nerd-fonts.jetbrains-mono

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    (pkgs.writeShellScriptBin "my-hello" ''
      echo "Hello, ${config.home.username}!"
    '')

    # Productivity tools
    pkgs.espanso
    pkgs.dust
    pkgs.xh
    pkgs.doggo
    pkgs.insomnia
    pkgs.libreoffice-qt
    pkgs.hunspell
    pkgs.hunspellDicts.es_MX
    pkgs.hunspellDicts.en_US

    # Wayland Essentials
    pkgs.waybar
    pkgs.rofi
    pkgs.hyprpaper
    pkgs.swaynotificationcenter
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.swww
    pkgs.eww
    pkgs.playerctl
    pkgs.brightnessctl
    pkgs.xfce.thunar
    pkgs.ghostty
    pkgs.github-desktop
    
    # Typst & PDF Power Tools
    pkgs.typst
    pkgs.tinymist
    pkgs.typstyle
    pkgs.hayagriva
    pkgs.pandoc
    pkgs.zathura
    pkgs.ghostscript
    pkgs.poppler-utils
    pkgs.ocrmypdf
    pkgs.chafa
    pkgs.imagemagick
    pkgs.python3Packages.pillow
    pkgs.ffmpegthumbnailer
    pkgs.atool
    pkgs.mediainfo
    pkgs.file
    (pkgs.callPackage ../../pkgs/img2webp.nix {})

    # Markdown Power Tools
    pkgs.glow
    pkgs.markdownlint-cli2
    pkgs.mermaid-cli
    pkgs.hugo
    pkgs.obsidian

    # Sync & Backup
    pkgs.maestral-gui
    pkgs.syncthing
    pkgs.syncthingtray
    pkgs.rclone
    pkgs.gnupg
    pkgs.pinentry-gnome3
    pkgs.rofi-pass-wayland

    # Locking & Idle
    pkgs.hyprlock
    pkgs.hypridle
    
    # Wallpaper & Display Management
    pkgs.waypaper
    pkgs.nwg-displays
    pkgs.hyprmon
    pkgs.wlr-randr # Required by nwg-displays for wlroots/hyprland

    # Browser & Tools
    inputs.antigravity-nix.packages."${pkgs.system}".google-antigravity-no-fhs
    inputs.wifitui.packages."${pkgs.system}".default
  ];

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "disk" "cpu" "memory" "pulseaudio" "network" "battery" "tray" "custom/power" ];
        
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };
        "clock" = {
          format = "{:%H:%M:%S}";
          interval = 1;
        };
        "disk" = {
          interval = 30;
          format = "󰋊 {percentage_used}%";
          path = "/";
          states = {
            warning = 80;
            critical = 90;
          };
        };
        "cpu" = {
          interval = 1;
          format = " {usage}%";
          states = {
            warning = 70;
            critical = 90;
          };
        };
        "memory" = {
          format = "󰍛 {percentage}%";
        };
        "network" = {
          format-wifi = " {essid} ({signalStrength}%)";
          format-ethernet = "󰈀 {ifname}";
          format-linked = "󰈀 {ifname} (No IP)";
          format-disconnected = "󰖪 Disconnected";
          tooltip-format = "{ifname} via {gwaddr} ";
          on-click = "ghostty -e wifitui";
        };
        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" ];
          };
          on-click = "pavucontrol";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "tray" = {
          spacing = 10;
        };

        "custom/power" = {
          format = "";
          on-click = "~/dotfiles/scripts/powermenu.sh";
          tooltip = false;
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }
      window#waybar {
        background-color: rgba(40, 42, 54, 0.8);
        border-bottom: 2px solid rgba(189, 147, 249, 0.5);
        color: #f8f8f2;
      }
      #workspaces button {
        padding: 0 5px;
        color: #f8f8f2;
      }
      #workspaces button.active {
        color: #bd93f9;
        border-bottom: 2px solid #bd93f9;
      }
      #clock, #pulseaudio, #network, #cpu, #memory, #disk, #tray {
        padding: 0 10px;
      }
      #tray {
        padding-right: 8px;
      }
      #tray > .passive,
      #tray > .active,
      #tray > .needs-attention {
        padding: 0 4px;
      }
      #cpu.warning, #disk.warning {
        color: #ffb86c;
      }
      #cpu.critical, #disk.critical {
        color: #ff5555;
      }
      #network {
        color: #8be9fd;
      }
      #cpu {
        color: #bd93f9;
      }
      #memory {
        color: #ff79c6;
      }
      #disk {
        color: #f1fa8c;
      }
      #custom-power {
        color: #ff5555;
        padding-right: 15px;
        font-size: 16px;
      }
      #battery {
        color: #50fa7b;
      }
      #battery.warning {
        color: #ffb86c;
      }
      #battery.critical:not(.charging) {
        color: #ff5555;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      @keyframes blink {
        to {
          background-color: #ff5555;
          color: #282a36;
        }
      }
    '';
  };

  programs.home-manager.enable = true;

  # Modern CLI tools
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.starship.enable = true;

  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      recolor-lightcolor = "#282a36";
      recolor-darkcolor = "#f8f8f2";
      default-bg = "#282a36";
      default-fg = "#f8f8f2";
      statusbar-bg = "#44475a";
      statusbar-fg = "#f8f8f2";
      inputbar-bg = "#282a36";
      inputbar-fg = "#8be9fd";
      notification-bg = "#282a36";
      notification-fg = "#f1fa8c";
      notification-error-bg = "#ff5555";
      notification-error-fg = "#f8f8f2";
      notification-warning-bg = "#ffb86c";
      notification-warning-fg = "#282a36";
      highlight-color = "#f1fa8c";
      highlight-active-color = "#bd93f9";
      completion-bg = "#282a36";
      completion-fg = "#6272a4";
      completion-highlight-bg = "#44475a";
      completion-highlight-fg = "#f8f8f2";
      index-bg = "#282a36";
      index-fg = "#f8f8f2";
      index-active-bg = "#44475a";
      index-active-fg = "#bd93f9";
      render-loading = true;
      render-loading-bg = "#282a36";
      render-loading-fg = "#f8f8f2";
      selection-clipboard = "clipboard";
      font = "JetBrainsMono Nerd Font 12";
    };
  };

  # Ranger with Spacemacs configuration
  programs.ranger = {
    enable = true;
    settings = {
      preview_images = true;
      preview_images_method = "chafa";
      use_preview_script = true;
      draw_borders = "both";
      unicode_ellipsis = true;
    };
    extraConfig = ''
      map e shell "$VISUAL" %f
      map E shell "$EDITOR" %f
    '';
  };

  # Developer tools
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Modern Shell Suite & Aliases
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons";
      l = "eza -l --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      find = "fd";
      du = "dust";
      ps = "procs";
      top = "btop";
      diff = "delta";
    };
    initContent = ''
      # Preserve existing .zshrc logic
      source ~/dotfiles/zsh/.zshrc
      
      # FNM (Fast Node Manager)
      eval "$(fnm env --use-on-cd)"
    '';
  };

  services.gpg-agent = {                          
	  enable = true;
	  defaultCacheTtl = 1800;
	  enableSshSupport = false;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
    };
  };

  services.syncthing.enable = true;

  systemd.user.services.rclone-gdrive-mount = {
    Unit = {
      Description = "rclone: Remote FUSE filesystem for Google Drive";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/GoogleDrive";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount marco.santana: %h/GoogleDrive \
          --vfs-cache-mode full \
          --vfs-cache-max-age 24h \
          --vfs-cache-max-size 10G \
          --vfs-read-chunk-size 32M \
          --no-modtime \
          --daemon-timeout 10m
      '';
      ExecStop = "/run/current-system/sw/bin/fusermount -u %h/GoogleDrive";
      Restart = "on-failure";
      RestartSec = "10s";
      Environment = [ "PATH=/run/current-system/sw/bin" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "MarcoSantana";
        email = "marco.santana@gmail.com";
      };
      color.ui = true;
      core.editor = "emacsclient -c -a ''";
      push.autoSetupRemote = true;
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
      syntax-theme = "Dracula";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "emacsclient -c -a ''";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
        rv = "repo view";
      };
    };
    extensions = [ pkgs.gh-dash ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
  };

  # Aesthetics for EXWM
  # services.picom = {
  #   enable = true;
  #   fade = true;
  #   shadow = true;
  #   opacityRules = [
  #     "90:class_g = 'Emacs'"
  #     "95:class_g = 'Ghostty'"
  #     "95:class_g = 'kitty'"
  #   ];
  #   settings = {
  #     blur = {
  #       method = "dual_kawase";
  #       strength = 5;
  #     };
  #   };
  # };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/ghostty/.config/ghostty";
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/kitty/.config/kitty";
    ".config/eww".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/eww";
    ".config/rofi".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/rofi";
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/msantana/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    BROWSER = "zen";
    # Wayland Fixes for Electron & other toolkits
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    WGPU_BACKEND = "vulkan";
    GTK_THEME = "Adwaita-dark";
  };

  # Set default applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
    };
  };

  # Make fonts available to the user environment
  fonts.fontconfig.enable = true;

  # GNOME Desktop configurations via dconf
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:nocaps" ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      minimize = [ ]; # Disable Super+h (minimize) to use it for focus-left
      
      # Focus (i3-like)
      focus-left = [ "<Super>h" ];
      focus-right = [ "<Super>l" ];
      focus-up = [ "<Super>k" ];
      focus-down = [ "<Super>j" ];

      # Move Windows (i3-like)
      move-to-side-e = [ "<Super><Shift>l" ];
      move-to-side-w = [ "<Super><Shift>h" ];
      move-to-side-n = [ "<Super><Shift>k" ];
      move-to-side-s = [ "<Super><Shift>j" ];
      
      # Fullscreen
      toggle-fullscreen = [ "<Super>f" ];
      
      # Tile windows with arrows (User requested keeping this GNOME feature)
      maximize-side-e = [ "<Super>Right" ];
      maximize-side-w = [ "<Super>Left" ];
      
      # Workspaces
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
      switch-to-workspace-0 = [ "<Super>0" ];
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      move-to-workspace-5 = [ "<Super><Shift>5" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Super>Escape" ]; # Remap lock from Super+l
      lock-screen = [ "<Super>Escape" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "ghostty";
      name = "Terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>b";
      command = "zen";
      name = "Browser";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>e";
      command = "emacsclient -c -a ''";
      name = "Spacemacs";
    };
  };

  # GTK Configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      vscodevim.vim
      ms-ceintl.vscode-language-pack-es
      
      # Vue 3 & Frontend
      vue.volar
      vue.vscode-typescript-vue-plugin
      bradlc.vscode-tailwindcss
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      
      # Backend & SQL
      ms-azuretools.vscode-docker
      redhat.vscode-yaml
      tamasfe.even-better-toml
      
      # Supabase & SQL
      supabase.supabase
    ];
    userSettings = {
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace'";
      "workbench.colorTheme" = "Dracula";
      "editor.formatOnSave" = true;
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = "active";
      "vim.useSystemClipboard" = true;
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
      "files.autoSave" = "afterDelay";
      "window.titleBarStyle" = "custom";
      "editor.inlineSuggest.enabled" = true;
    };
  };

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
