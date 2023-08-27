module App.Data.Id where

import AppPrelude
import Data.Argonaut (class DecodeJson, class EncodeJson)

newtype ActId
  = ActId Int

derive instance newtypeActId :: Newtype ActId _

derive newtype instance eqActId :: Eq ActId

derive newtype instance ordActId :: Ord ActId

derive newtype instance showActId :: Show ActId

derive newtype instance encodeJsonActId :: EncodeJson ActId

derive newtype instance decodeJsonActId :: DecodeJson ActId

newtype PackId
  = PackId Int

derive instance newtypePackId :: Newtype PackId _

derive newtype instance eqPackId :: Eq PackId

derive newtype instance ordPackId :: Ord PackId

derive newtype instance showPackId :: Show PackId

derive newtype instance encodeJsonPackId :: EncodeJson PackId

derive newtype instance decodeJsonPackId :: DecodeJson PackId

newtype ProblemId
  = ProblemId Int

derive instance newtypeProblemId :: Newtype ProblemId _

derive newtype instance eqProblemId :: Eq ProblemId

derive newtype instance ordProblemId :: Ord ProblemId

derive newtype instance showProblemId :: Show ProblemId

derive newtype instance encodeJsonProblemId :: EncodeJson ProblemId

derive newtype instance decodeJsonProblemId :: DecodeJson ProblemId

newtype SheetId
  = SheetId Int

derive instance newtypeSheetId :: Newtype SheetId _

derive newtype instance eqSheetId :: Eq SheetId

derive newtype instance ordSheetId :: Ord SheetId

derive newtype instance showSheetId :: Show SheetId

derive newtype instance encodeJsonSheetId :: EncodeJson SheetId

derive newtype instance decodeJsonSheetId :: DecodeJson SheetId

newtype SpecId
  = SpecId Int

derive instance newtypeSpecId :: Newtype SpecId _

derive newtype instance eqSpecId :: Eq SpecId

derive newtype instance ordSpecId :: Ord SpecId

derive newtype instance showSpecId :: Show SpecId

derive newtype instance encodeJsonSpecId :: EncodeJson SpecId

derive newtype instance decodeJsonSpecId :: DecodeJson SpecId

newtype UserId
  = UserId Int

derive instance newtypeUserId :: Newtype UserId _

derive newtype instance eqUserId :: Eq UserId

derive newtype instance ordUserId :: Ord UserId

derive newtype instance showUserId :: Show UserId

derive newtype instance encodeJsonUserId :: EncodeJson UserId

derive newtype instance decodeJsonUserId :: DecodeJson UserId
