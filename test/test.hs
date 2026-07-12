#!/usr/bin/env nix
#!nix shell --no-write-lock-file .?submodules=1#default --command sh -c ``haskell-script -- "$@"`` sh

{-# LANGUAGE NoImplicitPrelude #-}

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
