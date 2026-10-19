{
  description = "Fede's macOS development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hunk.url = "github:modem-dev/hunk";
    hunk.inputs.nixpkgs.follows = "nixpkgs";

    # The Herdr Worktrunk plugin requires >= 0.60; stable nixpkgs has 0.50.
    # Pin the upstream release without upgrading the rest of the environment.
    worktrunk.url = "github:max-sixty/worktrunk/v0.77.0";
    worktrunk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
      ...
    }:
    let
      user = "f_camposeco";
      host = "mac";
    in
    {
      darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user host; };
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "hm-backup";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit user host;
              inherit (inputs) hunk worktrunk;
            };
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
    };
}
