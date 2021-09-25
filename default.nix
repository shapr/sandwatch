{ compiler ? "ghc8107" }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  # bladespkgs = let
  #   src = pkgs.fetchFromGitLab {
  #     owner = "blades";
  #     repo = "bladespkgs";
  #     rev = "f1be0c17ec9dcc474fa0e81dd12cfd157d7631b6";
  #     sha256 = "03p2wsq9zrs45j9z63sp44hi86l7dwz4pmsianvbrymmpcm683br";
  #   };
  # in import src { inherit pkgs; };

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: hsuper: {
      "sandwatch" = hself.callCabal2nix "sandwatch" (gitignore ./.) { };
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: [ p."sandwatch" ];
    buildInputs = [
      myHaskellPackages.haskell-language-server
      pkgs.haskellPackages.cabal-install
      pkgs.haskellPackages.ghcid
      pkgs.haskellPackages.ormolu
      pkgs.haskellPackages.hlint
      pkgs.haskellPackages.hasktags
      pkgs.niv
      pkgs.nixpkgs-fmt
      # bladespkgs.tally
    ];
    withHoogle = true;
  };

  exe = pkgs.haskell.lib.justStaticExecutables (myHaskellPackages."sandwatch");

  docker = pkgs.dockerTools.buildImage {
    name = "sandwatch";
    config.Cmd = [ "${exe}/bin/sandwatch" ];
  };
in {
  inherit shell;
  inherit exe;
  inherit docker;
  inherit myHaskellPackages;
  "sandwatch" = myHaskellPackages."sandwatch";
}
