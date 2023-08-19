module App.View.Agent.NotificationAgent where

import AppViewPrelude
import App.Notification (Id(..), Level(..), Notification(..), Notifier)
import Data.Array as Array
import Data.Lens.Iso.Newtype (_Newtype)
import Effect.Console (logShow)
import Effect.Timer (setTimeout)
import React.Basic.Hooks as React

addNotification :: Notification -> Array Notification -> Array Notification
addNotification notification items = Array.snoc items notification

removeNotification :: Id -> Array Notification -> Array Notification
removeNotification idToRemove = Array.filter (\(Notification id _ _) -> id /= idToRemove)

foreign import data UseNotificationAgent :: Type -> Type

useNotificationAgent :: Hook UseNotificationAgent Notifier
useNotificationAgent =
  unsafeCoerceHook React.do
    items /\ setItems <- useState []
    nextId /\ setNextId <- useState (Id 0)
    let
      createNotification :: Level -> String -> Effect Unit
      createNotification level msg = do
        let
          notification = Notification nextId level msg
        -- Log Notification to console so that it is possible to go back to
        -- Notifications after they have disappeared.
        logShow notification
        -- Add notification
        setItems $ addNotification notification
        -- Automatically remove the notification after 5 seconds.
        _ <- setTimeout 5000 (setItems (removeNotification nextId))
        setNextId $ _Newtype %~ (_ + 1)
    pure
      { items
      , info: createNotification Info
      , warning: createNotification Warning
      , error: createNotification Error
      , reset: setItems \_ -> []
      }
