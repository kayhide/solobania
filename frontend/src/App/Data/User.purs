module App.Data.User
  ( User(..)
  , module App.Data.Id
  ) where

import AppPrelude
import App.Data.Id (UserId)
import App.Data.DateTime (decodeTimestamps, encodeTimestamps)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Data.DateTime (DateTime)

newtype User
  = User
  { id :: UserId
  , email :: String
  , username :: String
  , admin :: Boolean
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypeUser :: Newtype User _

derive newtype instance eqUser :: Eq User

derive newtype instance showUser :: Show User

instance encodeJsonUser :: EncodeJson User where
  encodeJson = encodeJson <<< encodeTimestamps <<< unwrap

instance decodeJsonUser :: DecodeJson User where
  decodeJson json = do
    obj <- decodeTimestamps =<< decodeJson json
    pure $ wrap obj
