module App.Data.User where

import AppPrelude
import App.Data.DateTime (decodeTimestamps, encodeTimestamps)
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Data.DateTime (DateTime)

newtype UserId
  = UserId Int

derive instance newtypeUserId :: Newtype UserId _

derive newtype instance eqUserId :: Eq UserId

derive newtype instance ordUserId :: Ord UserId

derive newtype instance showUserId :: Show UserId

derive newtype instance encodeJsonUserId :: EncodeJson UserId

derive newtype instance decodeJsonUserId :: DecodeJson UserId

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
