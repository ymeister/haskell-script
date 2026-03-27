{ pkgs ? import <nixpkgs> {}
, nix-shebang ? import ./deps/nix-shebang { inherit pkgs; }
, haskell-prelude-src ? ./deps/haskell-prelude
}:

with pkgs;

let base = nix-shebang.haskell.nix-haskell;
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
