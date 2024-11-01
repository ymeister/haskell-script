```
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
