{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprlock.nix
    ./hypridle.nix
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
    pkgs.btop
    pkgs.espanso
    pkgs.dust
    pkgs.xh
    pkgs.doggo
    pkgs.insomnia

    # TUI Power Tools
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.bottom

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
    pkgs.ranger
    pkgs.ghostty
    pkgs.github-desktop
    pkgs.neovim
    pkgs.neovide
    pkgs.rubyPackages_3_3.solargraph
    
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

    # Markdown Power Tools
    pkgs.glow
    pkgs.marksman
    pkgs.markdownlint-cli2
    pkgs.mermaid-cli
    pkgs.hugo
    pkgs.obsidian

    # Sync & Backup
    pkgs.maestral-gui
    pkgs.syncthing
    pkgs.syncthingtray
    pkgs.rclone

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

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      "$mod" = "SUPER";
      monitor = ",preferred,auto,1.25";
      xwayland = {
        force_zero_scaling = true;
      };
      input = {
        kb_options = "ctrl:nocaps";
      };
      exec-once = [
        "waybar"
        "swww init"
        "swww img /home/msantana/dotfiles/assets/wallpapers/orthodox_abstract_1.png"
        "nm-applet --indicator"
        "maestral_qt"
        "syncthingtray --wait"
        "swaync"
        "eww open keybinds_widget"
      ];
      bind = [
        "$mod, Return, exec, ghostty"
        "$mod, Q, killactive,"
        "$mod, SPACE, exec, rofi -show drun"
        "$mod, b, exec, zen"
        "$mod SHIFT, b, exec, google-chrome-stable"
        "$mod, m, fullscreen,"
        "$mod, D, exec, eww open --toggle dashboard"

        # Applications
        "$mod, e, exec, emacsclient -c -a ''"
        "$mod CONTROL, e, exec, emacsclient -c -a ''" # Emacs Anywhere shortcut
        "$mod, g, exec, ghostty -e lazygit"
        "$mod SHIFT, g, exec, github-desktop"
        "$mod SHIFT, n, exec, neovide"
        "$mod, p, exec, ghostty -e btop"
        "$mod SHIFT, p, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, v, exec, pavucontrol"
        "$mod, t, exec, ghostty -e btm"
        "$mod SHIFT, d, exec, insomnia"
        "$mod SHIFT, L, exec, loginctl lock-session"
        "$mod, w, exec, ghostty -e wifitui"
        "$mod SHIFT, m, exec, nwg-displays"
        "$mod, F1, exec, eww open --toggle keybinds_widget"
        
        # Focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Cycle Windows (a la Alt+Tab)
        "$mod, Tab, cyclenext,"
        "$mod SHIFT, Tab, cyclenext, prev"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Special Workspace
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Keybinds Helper
        "$mod, F1, exec, ~/dotfiles/scripts/keybinds.sh"
      ];
      bindel = [
        # Volume Control
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        
        # Brightness Control
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
      bindl = [
        # Media Control
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        # System Control
        ", XF86Display, exec, nwg-displays"
        ", XF86WLAN, exec, nmcli radio wifi toggle"
        ", XF86Search, exec, rofi -show drun"
        ", XF86KbdBrightnessUp, exec, brightnessctl -d *kbd_backlight* set +1"
        ", XF86KbdBrightnessDown, exec, brightnessctl -d *kbd_backlight* set 1-"
      ];
      decoration = {
        rounding = 15;
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          xray = true;
        };
        shadow = {
          enabled = true;
          range = 15;
          render_power = 4;
          color = "rgba(1a1a1aee)";
        };
        active_opacity = 0.95;
        inactive_opacity = 0.85;
      };
      animations = {
        enabled = "yes";
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };
      general = {
        gaps_in = 8;
        gaps_out = 15;
        border_size = 3;
        "col.active_border" = "rgba(ff79c6ee) rgba(bd93f9ee) 45deg";
        "col.inactive_border" = "rgba(44475aaa)";
        layout = "dwindle";
      };
    };
  };

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
      # Emacs Daemon Control
      emacs-start = "systemctl --user start emacs.service";
      emacs-stop = "systemctl --user stop emacs.service";
      emacs-restart = "systemctl --user restart emacs.service";
      e = "emacsclient -c -a ''";
    };
    initContent = ''
      # Preserve existing .zshrc logic
      source ~/dotfiles/zsh/.zshrc
    '';
  };

  services.emacs = {                              
	  enable = true;
    package = pkgs.emacs-unstable;
    client.enable = true;
    defaultEditor = false;
  };

  services.gpg-agent = {                          
	  enable = true;
	  defaultCacheTtl = 1800;
	  enableSshSupport = false;
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
        ${pkgs.rclone}/bin/rclone mount google-drive: %h/GoogleDrive \
          --vfs-cache-mode full \
          --vfs-cache-max-age 24h \
          --vfs-cache-max-size 10G \
          --vfs-read-chunk-size 32M \
          --no-modtime \
          --addr-refresh-interval 5m \
          --vfs-proxy-logging \
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
    userName = "MarcoSantana";
    userEmail = "marco.santana@gmail.com";
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
        syntax-theme = "Dracula";
      };
    };
    extraConfig = {
      color.ui = true;
      core.editor = "nvim";
      push.autoSetupRemote = true;
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
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
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/nvim/.config/nvim";
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/ghostty/.config/ghostty";
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/kitty/.config/kitty";
    ".config/emacs".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/emacs/.config/emacs";
    ".spacemacs".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/emacs/.spacemacs";
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
    EDITOR = "emacsclient -c -a ''";
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

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
