module App.View.Router where

import AppViewPrelude
import App.Data.Route (Route, routeCodec, navigate)
import App.Data.Route as Route
import App.View.Page.MitorizanPage as MitorizanPage
import App.View.Page.ShuzanPage as ShuzanPage
import App.View.Page.HomePage as HomePage
import App.Env (Env)
import App.Context (context)
import App.View.Agent.NotificationAgent (useNotificationAgent)
import React.Basic.Hooks (provider)
import React.Basic.Hooks as React
import Routing.Duplex (parse)
import Routing.Hash (matchesWith)

make :: Env -> Component {}
make env = do
  homePage <- HomePage.make
  mitorizanPage <- MitorizanPage.make
  shuzanPage <- ShuzanPage.make
  component "Router" \_ -> React.do
    route /\ setRoute <- useState Route.Home
    notifier <- useNotificationAgent
    movingTo /\ setMovingTo <- useState (Nothing :: Maybe Route)
    let
      currentProfile = Nothing

      authorize content = case currentProfile of
        -- Nothing -> element loginPage { sessions }
        Nothing -> content
        Just _ -> content
    useEffect unit do
      matchesWith (parse routeCodec) \_src dst -> do
        case dst of
          Route.Logout -> do
            navigate Route.Home
          _ -> setMovingTo $ const $ Just dst
    useEffect movingTo do
      for_ movingTo \route' ->
        when (route' /= route) do
          setRoute $ const route'
      pure $ pure unit
    pure
      $ provider context { env, notifier, route, currentProfile }
          [ case route of
              Route.Home -> authorize $ homePage {}
              Route.Mitorizan -> authorize $ mitorizanPage {}
              Route.Shuzan key -> authorize $ shuzanPage { key }
              Route.Login -> mempty
              Route.Logout -> mempty
          ]
