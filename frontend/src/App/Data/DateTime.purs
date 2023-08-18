module App.Data.DateTime where

import AppPrelude
import Data.Argonaut (JsonDecodeError(UnexpectedValue))
import Data.DateTime (Date, DateTime(..), date)
import Data.DateTime as DateTime
import Data.Formatter.Number as NumberFormatter
import Data.JSDate as JSDate
import Data.List (List(..), (:))
import Data.Newtype (class Newtype)
import Data.RFC3339String (fromDateTime, toDateTime)
import Data.Formatter.DateTime as DateTimeFormatter
import Data.String.Regex (Regex)
import Data.String.Regex as Regex
import Data.String.Regex.Flags (noFlags)
import Data.String.Regex.Unsafe (unsafeRegex)
import Data.Time (Time(..))
import Data.Time.Duration (Minutes(..), negateDuration)
import Record.Builder (build)
import Record.Builder as Builder

printDateTime :: DateTime -> String
printDateTime = unwrap <<< fromDateTime

parseDateTimeIn :: Timezone -> String -> Maybe DateTime
parseDateTimeIn timezone s = toDateTime $ wrap $ bool appendTimezoneOffset identity =<< Regex.test regex $ s
  where
  regex :: Regex
  regex = unsafeRegex "[-+][0-9]{2}:[0-9]{2}|Z$" noFlags

  appendTimezoneOffset :: String -> String
  appendTimezoneOffset s' =
    s'
      <> bool "" "+" (0.0 <= offsetMinutes)
      <> NumberFormatter.format fmt (offsetMinutes / 60.0)
      <> ":"
      <> NumberFormatter.format fmt (offsetMinutes `mod` 60.0)
    where
    offsetMinutes :: Number
    offsetMinutes = negate $ unwrap $ unwrap timezone

    fmt :: NumberFormatter.Formatter
    fmt = wrap { comma: false, before: 2, after: 0, abbreviations: false, sign: false }

parseDateTime :: String -> Maybe DateTime
parseDateTime = toDateTime <<< wrap

encodeDateTime :: DateTime -> Json
encodeDateTime = encodeJson <<< unwrap <<< fromDateTime

decodeDateTime :: Json -> Either JsonDecodeError DateTime
decodeDateTime json = do
  str <- decodeJson json
  note (UnexpectedValue json) $ toDateTime $ wrap str

-- | Follows rfc3339, good for `date` type of input form.
printDate :: Date -> String
printDate d = DateTimeFormatter.format f $ DateTime d bottom
  where
  f :: DateTimeFormatter.Formatter
  f =
    DateTimeFormatter.YearFull
      : DateTimeFormatter.Placeholder "-"
      : DateTimeFormatter.MonthTwoDigits
      : DateTimeFormatter.Placeholder "-"
      : DateTimeFormatter.DayOfMonthTwoDigits
      : Nil

-- | Follows rfc3339, good for `date` type of input form.
parseDate :: String -> Maybe Date
parseDate = map date <<< toDateTime <<< wrap

encodeDate :: Date -> Json
encodeDate = encodeJson <<< printDate

decodeDate :: Json -> Either JsonDecodeError Date
decodeDate json = do
  str <- decodeJson json
  note (UnexpectedValue json) $ parseDate str

localizeWith :: Timezone -> DateTime -> DateTime
localizeWith timezone dt =
  fromMaybe dt
    $ DateTime.adjust (negateDuration (unwrap timezone)) dt

globalizeWith :: Timezone -> DateTime -> DateTime
globalizeWith timezone dt =
  fromMaybe dt
    $ DateTime.adjust (unwrap timezone) dt

beginningOfDayIn :: Timezone -> DateTime -> DateTime
beginningOfDayIn timezone dt =
  globalizeWith timezone
    $ DateTime.modifyTime (const $ Time bottom bottom bottom bottom)
    $ localizeWith timezone dt

encodeTimestamps ::
  forall r.
  { created_at :: DateTime, updated_at :: DateTime | r } ->
  { created_at :: Json, updated_at :: Json | r }
encodeTimestamps obj =
  build
    ( Builder.modify (Proxy :: _ "created_at") (const $ encodeDateTime obj.created_at)
        <<< Builder.modify (Proxy :: _ "updated_at") (const $ encodeDateTime obj.updated_at)
    )
    obj

decodeTimestamps ::
  forall r.
  { created_at :: Json, updated_at :: Json | r } ->
  Either JsonDecodeError { created_at :: DateTime, updated_at :: DateTime | r }
decodeTimestamps obj = do
  created_at <- decodeDateTime obj.created_at
  updated_at <- decodeDateTime obj.updated_at
  pure
    $ build
        ( Builder.modify (Proxy :: _ "created_at") (const created_at)
            <<< Builder.modify (Proxy :: _ "updated_at") (const updated_at)
        )
        obj

newtype Timezone
  = Timezone Minutes

derive instance newtypeTimezone :: Newtype Timezone _

derive instance eqTimezone :: Eq Timezone

derive instance ordTimezone :: Ord Timezone

getTimezone :: Effect Timezone
getTimezone = do
  offset <- JSDate.getTimezoneOffset =<< JSDate.now
  pure $ Timezone $ Minutes offset
