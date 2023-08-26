module App.Data.Spec
  ( Spec(..)
  , module App.Data.Id
  ) where

import AppPrelude
import App.Data.Id (SpecId)
import App.Data.DateTime (decodeTimestamps, encodeTimestamps)
import Data.DateTime (DateTime)

newtype Spec
  = Spec
  { id :: SpecId
  , key :: String
  , name :: String
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypeSpec :: Newtype Spec _

derive newtype instance eqSpec :: Eq Spec

derive newtype instance showSpec :: Show Spec

instance encodeJsonSpec :: EncodeJson Spec where
  encodeJson = encodeJson <<< encodeTimestamps <<< unwrap

instance decodeJsonSpec :: DecodeJson Spec where
  decodeJson json = do
    obj <- decodeTimestamps =<< decodeJson json
    pure $ wrap obj
