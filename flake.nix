{
  description = "Custom builds of Iosevka";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    {
      overlays.default =
        final: prev:
        let
          pkgs = nixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system};
        in
        {
          inherit (pkgs) iosevka;
          voidevka = pkgs.iosevka.overrideAttrs rec {
            privateBuildPlan = builtins.readFile ./plans.toml;
            set = "voidevka";
          };

        };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        packages = {
          inherit (pkgs) iosevka voidevka;
        };
        defaultPackage = pkgs.voidevka;
      }
    );
}
