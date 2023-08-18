module App.View.Router where

import AppViewPrelude
import App.Data.Route (Route, routeCodec)
import App.Data.Route as Route
import App.Env (Env)
import React.Basic.DOM as R
import React.Basic.Hooks (createContext, provider)
import React.Basic.Hooks as React
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)
import Unsafe.Coerce (unsafeCoerce)

make :: Env -> Effect (ReactComponent {})
make env = do
  -- Context should be provided by `provider`, otherwise causes an esoteric runtime error.
  context <- createContext $ unsafeCoerce "Context is not set"
  reactComponent "Router" \_ -> React.do
    route /\ setRoute <- useState Route.Home
    let initialContext = {}
    let
      currentProfile = Just unit

      authorize content = case currentProfile of
        -- Nothing -> element loginPage { sessions }
        Nothing -> mempty
        Just _ -> content
    pure $
      provider context initialContext
            [ case route of
                Route.Home -> mempty # authorize
                Route.Login -> mempty # authorize
                Route.Logout -> mempty
            ]
