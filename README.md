# haskell-script

Run Haskell scripts as executables with automatic dependency management via Nix.

Uses [nix-shebang](https://github.com/ymeister/nix-shebang) for compilation and caching, with [haskell-prelude](https://github.com/ymeister/haskell-prelude) and `shh` included by default.

## Usage

```haskell
#!/usr/bin/env nix
#!nix shell --no-write-lock-file github:ymeister/haskell-script --command sh -c ``haskell-script -- "$@"`` sh

{-# LANGUAGE NoImplicitPrelude, PackageImports #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE TemplateHaskell #-}

import "prelude" Prelude
import Shh

$(loadEnv SearchPath)

main :: IO ()
main = do
  args <- getArgs
  if null args then do
    echo "Hello World!"
  else do
    echo $ "Hello" : args
```

```sh
chmod +x script.hs
./script.hs
```

### Shebang options

| Option | Description |
|---|---|
| `--deps <packages...>` | Extra Haskell package dependencies |
| `--opts <flags...>` | Extra GHC compiler flags |
| `--with <packages...>` | Non-Haskell system dependencies from nixpkgs |
| `--` | Separator between shebang args and script args |

### Defaults

`haskell-script` includes the following by default:

- **Dependencies**: `shh`, `prelude`
- **GHC flags**: `-O2 -threaded -rtsopts -with-rtsopts=-N`
- **Module**: [haskell-prelude](https://github.com/ymeister/haskell-prelude) overlay

### Commands

- **`haskell-script`** -- Compiles and runs the script.
- **`haskell-repl`** -- Opens GHCi with the script and its dependencies loaded.
