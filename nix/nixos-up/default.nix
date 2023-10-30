{
  python3,
  makeWrapper,
  lib,
  stdenv,
}: let
  python = python3.withPackages (ps: [ps.psutil ps.requests ps.jinja2]);
in
  stdenv.mkDerivation {
    name = "nixos-up";
    src = ../../.;
    unpackPhase = "true";
    buildInputs = [makeWrapper python];
    installPhase = ''
      mkdir -p $out/bin
      cp $src/nixos-up $out/bin/nixos-up
      wrapProgram $out/bin/nixos-up \
        --prefix PATH : ${lib.makeBinPath [python]}
    '';
  }
