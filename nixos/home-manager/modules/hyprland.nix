{ config, pkgs, ... }:

{
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
        "$mod SHIFT, p, exec, grim -g "$(slurp)" - | wl-copy"
        "$mod, v, exec, pavucontrol"
        "$mod, t, exec, ghostty -e btm"
        "$mod SHIFT, d, exec, insomnia"
        "$mod SHIFT, L, exec, loginctl lock-session"
        "$mod, w, exec, ghostty -e wifitui"
        "$mod SHIFT, m, exec, nwg-displays"
        "$mod, F1, exec, eww open --toggle keybinds_widget"
        "$mod CONTROL, F1, exec, eww open --toggle emacs_keybinds_widget"
        
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
}
