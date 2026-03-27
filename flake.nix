{
  inputs = {
    nix-shebang = {
      url = "git+file:./deps/nix-shebang?submodules=1";
    };

    haskell-prelude = {
      url = "git+file:./deps/haskell-prelude?submodules=1";
      flake = false;
    };

    nixpkgs.follows = "nix-shebang/nixpkgs";
  };

  outputs = inputs@{ self, nix-shebang, ... }:
    let nixpkgs = if inputs ? "nixpkgs" then inputs.nixpkgs else builtins.getFlake "nixpkgs";
        eachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in {
      packages = eachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
            project = pkgs.callPackage ./default.nix {
              inherit pkgs;
              nix-shebang = nix-shebang.packages.${system};
              haskell-prelude-src = inputs.haskell-prelude;
            };
        in {
          default = project;
        }
      );
    };
}
