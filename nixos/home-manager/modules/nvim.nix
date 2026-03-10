{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    # Treesitter dependencies
    extraPackages = with pkgs; [
      gcc
      gnumake
      unzip
      wget
      curl
    ];
  };

  home.packages = [
    pkgs.neovide
  ];

  home.file = {
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/msantana/dotfiles/nvim/.config/nvim";
  };

  home.sessionVariables = {
    EDITOR_ALT = "nvim";
  };
}
