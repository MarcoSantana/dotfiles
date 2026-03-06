{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.neovim
    pkgs.neovide
  ];

  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/nvim/.config/nvim";
  };

  home.sessionVariables = {
    EDITOR_ALT = "nvim";
  };
}
