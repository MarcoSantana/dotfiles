{ config, pkgs, inputs, ... }:

{
  home.username = "msantana";
  home.homeDirectory = "/home/msantana";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Admin & Debugging
    git
    wget
    curl
    ripgrep
    fd
    htop
    pciutils
    usbutils
    ghostty
    inputs.zen-browser.packages."${pkgs.system}".default
    
    # Simple editor for quick fixes (no Emacs/Neovim setup required here)
    vim
    
    # Modern communication for you
    slack
    discord
  ];

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

  programs.home-manager.enable = true;

  # Shell configuration for you on the MacBook
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
