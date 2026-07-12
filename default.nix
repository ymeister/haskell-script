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
    #
    default-extensions = [
      "GHC2024"
      "ApplicativeDo"
      "Arrows"
      "BangPatterns"
      "BinaryLiterals"
      "BlockArguments"
      "ConstrainedClassMethods"
      "ConstraintKinds"
      "DataKinds"
      "DefaultSignatures"
      "DeriveDataTypeable"
      "DeriveFoldable"
      "DeriveFunctor"
      "DeriveGeneric"
      "DeriveLift"
      "DeriveTraversable"
      "DerivingStrategies"
      "DerivingVia"
      "DisambiguateRecordFields"
      "DoAndIfThenElse"
      "DuplicateRecordFields"
      "EmptyCase"
      "EmptyDataDecls"
      "EmptyDataDeriving"
      "ExistentialQuantification"
      "ExplicitForAll"
      "ExplicitNamespaces"
      "ExtendedDefaultRules"
      "FlexibleContexts"
      "FlexibleInstances"
      "FunctionalDependencies"
      "GADTs"
      "GeneralizedNewtypeDeriving"
      "HexFloatLiterals"
      "ImportQualifiedPost"
      "ImpredicativeTypes"
      "InstanceSigs"
      "KindSignatures"
      "LambdaCase"
      "LexicalNegation"
      "LiberalTypeSynonyms"
      "MonadComprehensions"
      "MultilineStrings"
      "MultiParamTypeClasses"
      "MultiWayIf"
      "NamedDefaults"
      "NegativeLiterals"
      "NoAllowAmbiguousTypes"
      "NoDeriveAnyClass"
      "NoFieldSelectors"
      "NoNamedFieldPuns"
      "NoRecordWildCards"
      "NumericUnderscores"
      "OrPatterns"
      "OverloadedLabels"
      "OverloadedLists"
      "OverloadedRecordDot"
      "OverloadedRecordUpdate"
      "OverloadedStrings"
      "PackageImports"
      "ParallelListComp"
      "PartialTypeSignatures"
      "PatternGuards"
      "PatternSynonyms"
      "PolyKinds"
      "PostfixOperators"
      "QualifiedDo"
      "QuantifiedConstraints"
      "QuasiQuotes"
      "RankNTypes"
      "RecursiveDo"
      "RequiredTypeArguments"
      "RoleAnnotations"
      "ScopedTypeVariables"
      "StandaloneDeriving"
      "StandaloneKindSignatures"
      "TemplateHaskell"
      "TemplateHaskellQuotes"
      "TransformListComp"
      "TupleSections"
      "TypeApplications"
      "TypeData"
      "TypeFamilies"
      "TypeFamilyDependencies"
      "TypeOperators"
      "TypeSynonymInstances"
      "UndecidableInstances"
      "UnicodeSyntax"
      "ViewPatterns"
    ];

in symlinkJoin {
  name = "haskell-script";
  paths = [
    (
      writeScriptBin "haskell-script" ''
        #!/bin/sh

        exec "${base}/bin/nix-haskell-shebang" \
          --opts -O2 -fexpose-all-unfoldings -fspecialise -fspecialise-aggressively -flate-specialise -fcross-module-specialise \
          --opts -threaded -rtsopts -with-rtsopts=-N \
          --opts ${lib.concatMapStringsSep " " (ext: "-X${ext}") default-extensions} \
          --deps shh prelude \
          --module '(import ${prelude-overlay})' \
          --module '{ optimizations.all = true; }' \
          "$@"
      ''
    )
    (
      writeScriptBin "haskell-repl" ''
        #!/bin/sh

        exec "${base}/bin/nix-haskell-repl" \
          --opts ${lib.concatMapStringsSep " " (ext: "-X${ext}") default-extensions} \
          --deps shh prelude \
          --module '(import ${prelude-overlay})' \
          "$@"
      ''
    )
  ];
}
