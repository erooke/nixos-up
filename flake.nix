{
  description = "A dead simple install wizard for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    nixos-up = pkgs.callPackage nix/nixos-up {};
  in {
    formatter.${system} = pkgs.alejandra;

    apps.${system}.default = {
      type = "app";
      program = "${nixos-up}/bin/nixos-up";
    };

    packages.${system}.default = nixos-up;

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [pkgs.just] ++ nixos-up.buildInputs;
    };
  };
}
