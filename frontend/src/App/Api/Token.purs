module App.Api.Token where

import AppPrelude

newtype Token
  = Token String

derive instance newtypeToken :: Newtype Token _

derive instance eqToken :: Eq Token

derive instance ordToken :: Ord Token

derive newtype instance encodeJsonToken :: EncodeJson Token

derive newtype instance decodeJsonToken :: DecodeJson Token

instance showToken :: Show Token where
  show (Token _) = "Token {- token -}"
