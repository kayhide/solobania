module App.Data.Problem where

import AppPrelude
import App.Data.Id (ProblemId, SheetId)
import App.Data.DateTime (decodeTimestamps, encodeTimestamps)
import Data.Argonaut as Argonaut
import Data.DateTime (DateTime)

data Subject
  = Mitorizan
  | Kakezan
  | Warizan

derive instance genericSubject :: Generic Subject _

derive instance eqSubject :: Eq Subject

derive instance ordSubject :: Ord Subject

instance showSubject :: Show Subject where
  show = genericShow

instance encodeJsonSubject :: EncodeJson Subject where
  encodeJson = case _ of
    Mitorizan -> encodeJson "Mitorizan"
    Kakezan -> encodeJson "Kakezan"
    Warizan -> encodeJson "Warizan"

instance decodeJsonSubject :: DecodeJson Subject where
  decodeJson json = do
    decodeJson json
      >>= parseSubject
      >>> lmap (const $ Argonaut.UnexpectedValue json)

parseSubject :: String -> Either String Subject
parseSubject = case _ of
  "Mitorizan" -> pure Mitorizan
  "Kakezan" -> pure Kakezan
  "Warizan" -> pure Warizan
  v -> Left $ "Not a Subject: " <> v

newtype Body
  = Body
  { question :: Array Int
  , answer :: Int
  }

derive instance newtypeBody :: Newtype Body _

derive newtype instance eqBody :: Eq Body

derive newtype instance showBody :: Show Body

instance encodeJsonBody :: EncodeJson Body where
  encodeJson = encodeJson <<< unwrap

instance decodeJsonBody :: DecodeJson Body where
  decodeJson json = do
    obj <- decodeJson json
    pure $ wrap obj

newtype Problem
  = Problem
  { id :: ProblemId
  , sheet_id :: SheetId
  , subject :: Subject
  , count :: Int
  , body :: Body
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypeProblem :: Newtype Problem _

derive newtype instance eqProblem :: Eq Problem

derive newtype instance showProblem :: Show Problem

instance encodeJsonProblem :: EncodeJson Problem where
  encodeJson = encodeJson <<< encodeTimestamps <<< unwrap

instance decodeJsonProblem :: DecodeJson Problem where
  decodeJson json = do
    obj <- decodeTimestamps =<< decodeJson json
    pure $ wrap obj
