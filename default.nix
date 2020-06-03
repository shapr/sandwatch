{ sources ? import ./nix/sources.nix,
  pkgs ? import sources.nixpkgs {} }:
pkgs.haskell.packages.ghc8101.callPackage ./sandwatch.nix {}
