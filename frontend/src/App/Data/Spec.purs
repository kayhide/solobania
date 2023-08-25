module App.Data.Spec where

import AppPrelude
import App.Data.DateTime (decodeTimestamps, encodeTimestamps)
import Data.DateTime (DateTime)

newtype SpecId
  = SpecId Int

derive instance newtypeSpecId :: Newtype SpecId _

derive newtype instance eqSpecId :: Eq SpecId

derive newtype instance ordSpecId :: Ord SpecId

derive newtype instance showSpecId :: Show SpecId

derive newtype instance encodeJsonSpecId :: EncodeJson SpecId

derive newtype instance decodeJsonSpecId :: DecodeJson SpecId

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
