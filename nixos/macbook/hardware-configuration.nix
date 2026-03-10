# This is a placeholder for hardware-configuration.nix
# On the actual MacBook, run:
# sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
# then replace this file with the generated one.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "firewire_ohci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Minimal file systems placeholder - PLEASE REGENERATE ON DEVICE
  # sudo nixos-generate-config --show-hardware-config > nixos/macbook/hardware-configuration.nix
  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos"; # Ensure your root partition is labeled 'nixos'
      fsType = "ext4";
    };

  # EFI boot partition
  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot"; # Ensure your EFI partition is labeled 'boot'
      fsType = "vfat";
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
