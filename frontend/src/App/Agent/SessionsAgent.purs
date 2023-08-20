module App.View.Agent.SessionsAgent where

import AppViewPrelude
import App.Api.Request (login, readToken, removeToken, verifyToken, writeToken)
import App.Api.Token (Token)
import App.Data.User (User)
import App.Env (Env)
import App.Notification (Notifier)
import React.Basic.Hooks as React

type SessionsAgent
  = { user :: Maybe User
    , token :: Maybe Token
    , isReady :: Boolean
    , isBusy :: Boolean
    , login :: EmailPassword -> Effect Unit
    , logout :: Effect Unit
    }

foreign import data UseSessionsAgent :: Type -> Type

type EmailPassword
  = { email :: String
    , password :: String
    }

type ProfileToken
  = { user :: User
    , token :: Token
    }

useSessionsAgent :: Env -> Notifier -> Hook UseSessionsAgent SessionsAgent
useSessionsAgent env notifier =
  unsafeCoerceHook React.do
    profile /\ setProfile <- useState (Nothing :: Maybe ProfileToken)
    isReady /\ setIsReady <- useState false
    verifying /\ setVerifying <- useState (Nothing :: Maybe Token)
    loggingin /\ setLoggingin <- useState (Nothing :: Maybe EmailPassword)
    useEffect unit do
      setVerifying <<< const =<< readToken
      pure $ pure unit
    useEffect profile do
      when isReady do
        maybe removeToken writeToken $ _.token <$> profile
      pure $ pure unit
    useAff verifying do
      for_ verifying \token -> do
        x <- verifyToken env.baseUrl token
        liftEffect do
          case x of
            Left err -> notifier.error $ "Error occurred when trying to verify user token: " <> err
            Right user -> do
              setProfile $ const $ Just { user, token }
          setVerifying $ const Nothing
    useAff loggingin do
      for_ loggingin \loggingin' -> do
        eitherUserInfo <- login env.baseUrl loggingin'
        liftEffect do
          case eitherUserInfo of
            Left err -> notifier.error $ "Error occurred when trying to login: " <> err
            Right (token /\ user) -> do
              setProfile $ const $ Just { user, token }
          setLoggingin $ const Nothing
    useEffect (isJust verifying) do
      when (not isReady) do
        when (isNothing verifying) do
          setIsReady $ const true
      pure $ pure unit
    pure
      { user: _.user <$> profile
      , token: _.token <$> profile
      , isReady
      , isBusy: isJust verifying || isJust loggingin
      , login: setLoggingin <<< const <<< Just
      , logout: setProfile $ const Nothing
      }
