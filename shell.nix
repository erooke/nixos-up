{pkgs ? import <nixpkgs> {}}: let
  nixos-up = pkgs.callPackage ./nix/nixos-up {};
in
  pkgs.mkShell {
    name = "nixos-up";
    buildInputs = [nixos-up];
    shellHook = "exec ${nixos-up}/bin/nixos-up";
  }
