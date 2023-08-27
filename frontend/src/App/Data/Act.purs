module App.Data.Act
  ( Mark(..)
  , ActableId
  , Act(..)
  , CreatingAct(..)
  , UpdatingAct(..)
  , module App.Data.Id
  ) where

import AppPrelude
import App.Data (class Updating)
import App.Data.DateTime (decodeTimestamps)
import App.Data.Id (ActId, PackId, ProblemId, SheetId)
import Data.Argonaut (JsonDecodeError(..))
import Data.Argonaut as Argonaut
import Data.DateTime (DateTime)
import Data.Lens (lens)
import Prim.Row (class Lacks)
import Record.Builder (build)
import Record.Builder as Builder

data Mark
  = Confident
  | Hesitant
  | Uncertain

derive instance genericMark :: Generic Mark _

derive instance eqMark :: Eq Mark

derive instance ordMark :: Ord Mark

instance showMark :: Show Mark where
  show = genericShow

instance encodeJsonMark :: EncodeJson Mark where
  encodeJson = case _ of
    Confident -> encodeJson "confident"
    Hesitant -> encodeJson "hesitant"
    Uncertain -> encodeJson "uncertain"

instance decodeJsonMark :: DecodeJson Mark where
  decodeJson json = do
    decodeJson json
      >>= parseMark
      >>> lmap (const $ Argonaut.UnexpectedValue json)

parseMark :: String -> Either String Mark
parseMark = case _ of
  "confident" -> pure Confident
  "hesitant" -> pure Hesitant
  "uncertain" -> pure Uncertain
  v -> Left $ "Not a Mark: " <> v

type ActableId
  = ProblemId \/ SheetId \/ PackId \/ Void

decodeActable ::
  forall r.
  Lacks "actable_type" r =>
  Lacks "actable_id" r =>
  { actable_type :: Json, actable_id :: Json | r } ->
  Either JsonDecodeError { actable_id :: ActableId | r }
decodeActable obj = do
  actable_type <- decodeJson obj.actable_type
  actable_id <- decodeJson obj.actable_id
  actable_id' <- case actable_type of
    "Problem" -> pure $ in1 $ wrap actable_id
    "Sheet" -> pure $ in2 $ wrap actable_id
    "Pack" -> pure $ in3 $ wrap actable_id
    _ -> Left $ UnexpectedValue obj.actable_type
  pure
    $ build
        ( Builder.modify (Proxy :: _ "actable_id") (const actable_id')
            <<< Builder.delete (Proxy :: _ "actable_type")
        )
        obj

newtype Act
  = Act
  { id :: ActId
  , actable_id :: ActableId
  , display_name :: String
  , pack_id :: Maybe PackId
  , sheet_id :: Maybe SheetId
  , problem_id :: Maybe ProblemId
  , mark :: Maybe Mark
  , created_at :: DateTime
  , updated_at :: DateTime
  }

derive instance newtypeAct :: Newtype Act _

derive newtype instance eqAct :: Eq Act

derive newtype instance showAct :: Show Act

instance decodeJsonAct :: DecodeJson Act where
  decodeJson json = do
    obj <- decodeActable =<< decodeTimestamps =<< decodeJson json
    pure $ wrap obj

newtype CreatingAct
  = CreatingAct Unit

derive instance newtypeCreatingAct :: Newtype CreatingAct _

derive newtype instance eqCreatingAct :: Eq CreatingAct

derive newtype instance showCreatingAct :: Show CreatingAct

derive newtype instance encodeJsonCreatingAct :: EncodeJson CreatingAct

derive newtype instance decodeJsonCreatingAct :: DecodeJson CreatingAct

newtype UpdatingAct
  = UpdatingAct
  { mark :: Maybe Mark
  }

derive instance newtypeUpdatingAct :: Newtype UpdatingAct _

derive newtype instance eqUpdatingAct :: Eq UpdatingAct

derive newtype instance showUpdatingAct :: Show UpdatingAct

derive newtype instance encodeJsonUpdatingAct :: EncodeJson UpdatingAct

instance updatingAct :: Updating Act UpdatingAct where
  _Updating = lens get set
    where
    get :: Act -> UpdatingAct
    get (Act { mark }) = UpdatingAct { mark }

    set :: Act -> UpdatingAct -> Act
    set (Act obj) (UpdatingAct { mark }) =
      Act
        $ obj { mark = mark }
