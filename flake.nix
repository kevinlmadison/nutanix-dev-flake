{
  description = "Kevin's NixOS Flake";

  inputs = {
    # Some cool flake utils for smooth configuration
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    # Nix Packages
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Peronal Neovim Flake
    neovim-flake.url = "github:kevinlmadison/neovim-flake";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    neovim-flake,
    ...
  } @ inputs: let
    username = "kubezt";
    stateVersion = "24.05";
    home-modules = {
      home-manager.backupFileExtension = "bak";
      home-manager.useGlobalPkgs = false;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {inherit inputs username stateVersion;};
      home-manager.users.kubezt = import ./home.nix;
    };
  in {
    nixosConfigurations = {
      "nuvm" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./hosts/nuvm/default.nix
          home-manager.nixosModules.home-manager
          home-modules
        ];
      };
    };
  };
}
