module App.View.Helper.KeyboardShortcut where

import AppViewPrelude
import App.View.Helper.GlobalEvent (onEvent, offEvent)
import Data.Map as Map
import React.Basic.Hooks as React

type KeyboardShortcut
  = { register :: String -> Effect Unit -> Effect Unit
    , unregister :: String -> Effect Unit
    }

foreign import data UseKeyboardShortcut :: Type -> Type

useKeyboardShortcut :: Hook UseKeyboardShortcut KeyboardShortcut
useKeyboardShortcut =
  unsafeCoerceHook React.do
    generation /\ setGeneration <- useState 0
    table /\ setTable <- useState (empty :: Map String (Effect Unit))
    let
      handleKeyDown { key } = do
        for_ (Map.lookup key table) \f -> f
        pure unit
    useEffect generation do
      keydown <- onEvent "keydown" handleKeyDown
      pure do
        offEvent "keydown" keydown
    pure
      { register:
          \key f -> do
            setTable (Map.insert key f)
            setGeneration (_ + 1)
      , unregister:
          \key -> do
            setTable (Map.delete key)
            setGeneration (_ + 1)
      }
