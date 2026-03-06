{ config, pkgs, ... }:

{
  services.emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
    client.enable = true;
    defaultEditor = false;
  };

  home.file = {
    ".config/emacs".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/emacs/.config/emacs";
    ".spacemacs".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/emacs/.spacemacs";
  };

  home.sessionVariables = {
    EDITOR = "emacsclient -c -a ''";
  };

  programs.zsh.shellAliases = {
    emacs-start = "systemctl --user start emacs.service";
    emacs-stop = "systemctl --user stop emacs.service";
    emacs-restart = "systemctl --user restart emacs.service";
    e = "emacsclient -c -a ''";
  };
}
