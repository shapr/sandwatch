{ sources ? import ./nix/sources.nix,
  pkgs ? import sources.nixpkgs {} }:

let
  sandwatch = import ./default.nix { inherit sources pkgs; };
in pkgs.mkShell {
  buildInputs = sandwatch.env.nativeBuildInputs ++ [
    pkgs.haskell.packages.ghc8101.cabal-install
  ];
}

