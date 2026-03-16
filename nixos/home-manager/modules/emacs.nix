{ config, pkgs, ... }:

{
  services.emacs = {
    enable = true;
    package = pkgs.emacs-unstable-pgtk;
    client.enable = true;
    defaultEditor = false;
  };

  # Extra Emacs Dependencies
  home.packages = with pkgs; [
    # Spell checking
    ispell
    aspell
    aspellDicts.es
    aspellDicts.en
    aspellDicts.en-computers

    # Build tools for Emacs packages (e.g. vterm, pdf-tools)
    libtool
    cmake
    pkg-config
    gnutls
    imagemagick
  ];

  home.file = {
    ".config/emacs".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/emacs/.config/emacs";
    ".spacemacs".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/emacs/.spacemacs";
  };

  home.sessionVariables = {
    EDITOR = "emacsclient -t -a ''";
    VISUAL = "emacsclient -c -a ''";
  };

  programs.zsh.shellAliases = {
    emacs-start = "systemctl --user start emacs.service";
    emacs-stop = "systemctl --user stop emacs.service";
    emacs-restart = "systemctl --user restart emacs.service";
    e = "emacsclient -c -a ''";
  };
}
