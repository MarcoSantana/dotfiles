# Version: 2026-11-01
{ config, pkgs, lib, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [ "https://cosmic.cachix.org/" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:D7qyvSTqdRe0u3VGEzlDnuMC8S4+X88G9h88vB1C2dE=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages for all hosts
  nixpkgs.config.allowUnfree = true;

  # Enable COSMIC Desktop as fallback
  services.desktopManager.cosmic.enable = true;

  # Container Runtimes
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.docker.enable = true;

  # Limit the number of generations shown in the boot menu
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
}
