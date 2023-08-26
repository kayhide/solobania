module App.Font where

import AppPrelude

type LabelValue
  = { label :: String
    , value :: String
    }

type Font
  = { current :: String
    , set :: String -> Effect Unit
    , options :: Array LabelValue
    }
