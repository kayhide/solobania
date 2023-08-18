module App.Api.Request where

import AppPrelude

newtype BaseUrl
  = BaseUrl String

derive instance newtypeBaseUrl :: Newtype BaseUrl _
