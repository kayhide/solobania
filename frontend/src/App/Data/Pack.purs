module App.Data.Pack
  ( Category(..)
  , Pack(..)
  , CreatingPack(..)
  , module App.Data.Id
  ) where

import AppPrelude
import App.Data.Id (PackId)
import App.Data.Sheet (Sheet)
import App.Data.DateTime (decodeTimestamps, encodeTimestamps)
import Data.Argonaut as Argonaut
import Data.DateTime (DateTime)

data Category
  = Shuzan
  | Anzan

derive instance genericCategory :: Generic Category _

derive instance eqCategory :: Eq Category

derive instance ordCategory :: Ord Category

instance showCategory :: Show Category where
  show = genericShow

instance encodeJsonCategory :: EncodeJson Category where
  encodeJson = case _ of
    Shuzan -> encodeJson "shuzan"
    Anzan -> encodeJson "anzan"

instance decodeJsonCategory :: DecodeJson Category where
  decodeJson json = do
    decodeJson json
      >>= parseCategory
      >>> lmap (const $ Argonaut.UnexpectedValue json)

parseCategory :: String -> Either String Category
parseCategory = case _ of
  "shuzan" -> pure Shuzan
  "anzan" -> pure Anzan
  v -> Left $ "Not a Category: " <> v

newtype Pack
  = Pack
  { id :: PackId
  , category :: Category
  , name :: String
  , sheets :: Array Sheet
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypePack :: Newtype Pack _

derive newtype instance eqPack :: Eq Pack

derive newtype instance showPack :: Show Pack

instance encodeJsonPack :: EncodeJson Pack where
  encodeJson = encodeJson <<< encodeTimestamps <<< unwrap

instance decodeJsonPack :: DecodeJson Pack where
  decodeJson json = do
    obj <- decodeTimestamps =<< decodeJson json
    pure $ wrap obj

newtype CreatingPack
  = CreatingPack Unit

derive instance newtypeCreatingPack :: Newtype CreatingPack _

derive newtype instance eqCreatingPack :: Eq CreatingPack

derive newtype instance showCreatingPack :: Show CreatingPack

derive newtype instance encodeJsonCreatingPack :: EncodeJson CreatingPack

derive newtype instance decodeJsonCreatingPack :: DecodeJson CreatingPack
