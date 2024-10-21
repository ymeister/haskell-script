{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let nix-thunk = import ./deps/nix-thunk { inherit pkgs; };
    deps = with nix-thunk; mapSubdirectories thunkSource ./deps;

    haskell-shebang = import deps.haskell-shebang { pkgs = pkgs; };

in symlinkJoin {
  name = "haskell-shebang";
  paths = [
    (
      writeScriptBin "haskell-script" ''
        #!/bin/sh

        exec "${haskell-shebang}/bin/haskell-shebang" shh "$@"
      ''
    )
    (
      writeScriptBin "haskell-repl" ''
        #!/bin/sh

        exec "${haskell-shebang}/bin/haskell-repl" shh "$@"
      ''
    )
  ];
}
