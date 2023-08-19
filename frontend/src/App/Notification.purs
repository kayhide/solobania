module App.Notification where

import AppPrelude

newtype Id
  = Id Int

derive instance newtypeId :: Newtype Id _

derive newtype instance eqId :: Eq Id

derive newtype instance showId :: Show Id

data Notification
  = Notification Id Level String

derive instance genericNotification :: Generic Notification _

instance showNotification :: Show Notification where
  show = genericShow

data Level
  = Info
  | Warning
  | Error

derive instance genericLevel :: Generic Level _

instance showLevel :: Show Level where
  show = genericShow

type Notifier
  = { items :: Array Notification
    , info :: String -> Effect Unit
    , warning :: String -> Effect Unit
    , error :: String -> Effect Unit
    , reset :: Effect Unit
    }
