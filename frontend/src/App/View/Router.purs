module App.View.Router where

import AppViewPrelude
import App.Data.Route (Route, routeCodec, navigate)
import App.Data.Route as Route
import App.View.Agent.StoreAgent (useStoreAgent)
import App.View.Page.HomePage as HomePage
import App.View.Page.LoginPage as LoginPage
import App.View.Page.MitorizanPage as MitorizanPage
import App.View.Page.PackPage as PackPage
import App.View.Page.ShuzanPage as ShuzanPage
import App.Env (Env)
import App.Context (context)
import App.View.Agent.FontAgent (useFontAgent)
import App.View.Agent.NotificationAgent (useNotificationAgent)
import App.View.Agent.SessionsAgent (useSessionsAgent)
import React.Basic.Hooks (provider)
import React.Basic.Hooks as React
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)

make :: Env -> Component {}
make env = do
  component "Router" \_ -> React.do
    route /\ setRoute <- useState Route.Home
    notifier <- useNotificationAgent
    sessions <- useSessionsAgent env notifier
    store <- useStoreAgent
    font <- useFontAgent
    movingTo /\ setMovingTo <- useState (Nothing :: Maybe Route)
    let
      currentProfile = { user: _ } <$> sessions.user

      authorize content = case currentProfile of
        Nothing -> LoginPage.render { sessions }
        Just _ -> content
    useEffect unit do
      matchesWith (parse routeCodec) \_src dst -> do
        case dst, currentProfile of
          Route.Login, Just _ -> do
            navigate Route.Home
          Route.Logout, _ -> do
            sessions.logout
            navigate Route.Home
          _, _ -> setMovingTo $ const $ Just dst
    useEffect movingTo do
      for_ movingTo \route' ->
        when (route' /= route) do
          setRoute $ const route'
      pure $ pure unit
    pure $ sessions.isReady
      # bool mempty do
          provider context { env, notifier, route, currentProfile, store, font }
            [ case route of
                Route.Home -> authorize $ HomePage.render {}
                Route.Login -> authorize $ mempty
                Route.Logout -> mempty
                Route.Mitorizan -> authorize $ MitorizanPage.render {}
                Route.Shuzan key -> authorize $ ShuzanPage.render { key }
                Route.Pack packId -> authorize $ PackPage.render { packId }
            ]
