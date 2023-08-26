module App.Data.Sheet where

import AppPrelude
import App.Data.Id (PackId, SheetId)
import App.Data.Problem (Problem)
import App.Data.DateTime (decodeTimestamps, encodeTimestamps)
import Data.DateTime (DateTime)

newtype Sheet
  = Sheet
  { id :: SheetId
  , pack_id :: PackId
  , name :: String
  , problems :: Array Problem
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypeSheet :: Newtype Sheet _

derive newtype instance eqSheet :: Eq Sheet

derive newtype instance showSheet :: Show Sheet

instance encodeJsonSheet :: EncodeJson Sheet where
  encodeJson = encodeJson <<< encodeTimestamps <<< unwrap

instance decodeJsonSheet :: DecodeJson Sheet where
  decodeJson json = do
    obj <- decodeTimestamps =<< decodeJson json
    pure $ wrap obj
