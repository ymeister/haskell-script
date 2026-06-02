{ inputs ? (import ./inputs.nix)
, system ? builtins.currentSystem
, pkgs ? (import inputs.nixpkgs { inherit system; })
}:

with pkgs;

let nix-shebang-src = inputs.nix-shebang or ./deps/nix-shebang;
    nix-shebang = import nix-shebang-src { inherit inputs system pkgs; };
    #
    haskell-prelude-src = inputs.haskell-prelude or ./deps/haskell-prelude;
    haskell-prelude = import haskell-prelude-src { inherit inputs system pkgs; };
    #
    base = nix-shebang.haskell.nix-haskell;
    prelude-overlay = haskell-prelude-src + "/overlay/nix-haskell.nix";

in symlinkJoin {
  name = "haskell-script";
  paths = [
    (
      writeScriptBin "haskell-script" ''
        #!/bin/sh

        exec "${base}/bin/nix-haskell-shebang" --opts -O2 -threaded -rtsopts -with-rtsopts=-N --deps shh prelude --module '(import ${prelude-overlay})' "$@"
      ''
    )
    (
      writeScriptBin "haskell-repl" ''
        #!/bin/sh

        exec "${base}/bin/nix-haskell-repl" --deps shh prelude --module '(import ${prelude-overlay})' "$@"
      ''
    )
  ];
}
