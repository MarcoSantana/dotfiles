{ config, pkgs, ... }:

{
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
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

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
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      "$mod" = "SUPER";
      exec-once = [
        "waybar"
        "swww init"
        "nm-applet --indicator"
        "swaync"
      ];
      bind = [
        "$mod, Return, exec, ghostty"
        "$mod, Q, killactive,"
        "$mod, B, exec, firefox"
        "$mod, SPACE, exec, rofi -show drun"
        "$mod, F, fullscreen,"
        "$mod, D, exec, eww open --toggle dashboard"
        
        # Focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

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
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "tray" ];
        
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };
        "clock" = {
          format = "{:%H:%M:%S}";
          interval = 1;
        };
        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" ];
          };
          on-click = "pavucontrol";
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
      #clock, #pulseaudio, #network, #cpu, #memory, #tray {
        padding: 0 10px;
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
    '';
  };

  programs.emacs = {                              
	  enable = true;
    package = pkgs.emacs-unstable;
	  extraPackages = epkgs: [
		  epkgs.nix-mode
		  epkgs.magit
	  ];
  };

  services.gpg-agent = {                          
	  enable = true;
	  defaultCacheTtl = 1800;
	  enableSshSupport = true;
  };

  # Aesthetics for EXWM
  services.picom = {
    enable = true;
    fade = true;
    shadow = true;
    opacityRules = [
      "90:class_g = 'Emacs'"
      "95:class_g = 'Ghostty'"
      "95:class_g = 'kitty'"
    ];
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 5;
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/nvim/.config/nvim";
    ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/ghostty/.config/ghostty";
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/kitty/.config/kitty";
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
    EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
}
