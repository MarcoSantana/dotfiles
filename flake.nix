{
  description = "Marco's Unified NixOS and Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wifitui = {
      url = "github:shazow/wifitui";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, zen-browser, nixos-hardware, wifitui, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.msantana = import ./nixos/home-manager/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ emacs-overlay.overlays.default ];
          })
        ];
      };

      nixosConfigurations.macbook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-11-5 # Baseline for older MBPs
          ./nixos/macbook/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dcampuzano = import ./nixos/macbook/home.nix;
            home-manager.users.msantana = import ./nixos/macbook/msantana.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ emacs-overlay.overlays.default ];
          })
        ];
      };

      nixosConfigurations.lenovoL13 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-l13
          ./nixos/lenovoL13/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.msantana = import ./nixos/home-manager/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ emacs-overlay.overlays.default ];
          })
        ];
      };
    };
}
