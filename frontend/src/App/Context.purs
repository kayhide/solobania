module App.Context where

import AppPrelude
import App.Data.Route (Route)
import App.Data.User (User)
import App.Env (Env)
import App.Notification (Notifier)
import App.Store (Store)
import App.Font (Font)
import React.Basic.Hooks (ReactContext, createContext)

type Profile
  = { user :: User
    }

type ContextRecord
  = { env :: Env
    , notifier :: Notifier
    , route :: Route
    , currentProfile :: Maybe Profile
    , store :: Store
    , font :: Font
    }

-- | Context holds data which is widely refered to among components.
type Context
  = ReactContext ContextRecord

-- | This instance is a kind of reference shared by components globally.
context :: Context
context =
  unsafePerformEffect
    $ createContext
    $ unsafeCoerce "Context is not set"
