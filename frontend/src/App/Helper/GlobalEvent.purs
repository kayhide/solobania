module App.View.Helper.GlobalEvent where

import AppViewPrelude

foreign import data Listener :: Type

type EventType
  = String

foreign import onEvent :: forall e. EventType -> (e -> Effect Unit) -> Effect Listener

foreign import offEvent :: EventType -> Listener -> Effect Unit
