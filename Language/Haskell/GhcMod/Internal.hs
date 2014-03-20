-- | Low level access to the ghc-mod library.

module Language.Haskell.GhcMod.Internal (
  -- * Types
    LogReader
  , GHCOption
  , Package
  , IncludeDir
  , CompilerOptions(..)
  -- * Cabal API
  , parseCabalFile
  , getCompilerOptions
  , cabalAllBuildInfo
  , cabalDependPackages
  , cabalSourceDirs
  , cabalAllTargets
  -- * Getting 'DynFlags'
  , getDynamicFlags
  -- * Initializing 'DynFlags'
  , initializeFlags
  , initializeFlagsWithCradle
  -- * 'GhcMonad'
  , setTargetFiles
  , addTargetFiles
  , handleErrMsg
  -- * 'Ghc' Choice
  , (||>)
  , goNext
  , runAnyOne
  -- * 'GhcMonad' Choice
  , (|||>)
  -- * GHC
  , getSystemLibDir
  ) where

import Language.Haskell.GhcMod.CabalApi
import Language.Haskell.GhcMod.ErrMsg
import Language.Haskell.GhcMod.GHCApi
import Language.Haskell.GhcMod.GHCChoice
import Language.Haskell.GhcMod.Types
