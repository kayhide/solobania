module App.View.Router where

import AppViewPrelude
import App.Data.Route (Route, routeCodec, navigate)
import App.Data.Route as Route
import App.View.Page.MitorizanPage as MitorizanPage
import App.View.Page.ShuzanPage as ShuzanPage
import App.View.Page.HomePage as HomePage
import App.View.Page.LoginPage as LoginPage
import App.Env (Env)
import App.Context (context)
import App.View.Agent.NotificationAgent (useNotificationAgent)
import App.View.Agent.SessionsAgent (useSessionsAgent)
import React.Basic.Hooks (provider)
import React.Basic.Hooks as React
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)

make :: Env -> Component {}
make env = do
  homePage <- HomePage.make
  loginPage <- LoginPage.make
  mitorizanPage <- MitorizanPage.make
  shuzanPage <- ShuzanPage.make
  component "Router" \_ -> React.do
    route /\ setRoute <- useState Route.Home
    notifier <- useNotificationAgent
    sessions <- useSessionsAgent env notifier
    movingTo /\ setMovingTo <- useState (Nothing :: Maybe Route)
    let
      currentProfile = { user: _ } <$> sessions.user

      authorize content = case currentProfile of
        Nothing -> loginPage { sessions }
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
          provider context { env, notifier, route, currentProfile }
            [ case route of
                Route.Home -> authorize $ homePage {}
                Route.Mitorizan -> authorize $ mitorizanPage {}
                Route.Shuzan key -> authorize $ shuzanPage { key }
                Route.Login -> authorize $ mempty
                Route.Logout -> mempty
            ]
