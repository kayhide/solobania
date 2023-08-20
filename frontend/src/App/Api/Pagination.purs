module App.Api.Pagination where

import AppPrelude
import Data.Array as Array
import Data.Int as Int
import Data.String as String
import Data.Maybe (Maybe(..))

type Pagination
  = { contentRange :: Maybe ContentRange
    , nextRange :: Maybe NextRange
    , totalCount :: Maybe Int
    }

type Paginated a
  = { body :: a, pagination :: Pagination }

type Range
  = { field :: String
    , limit :: Maybe Int
    , offset :: Maybe Int
    , descending :: Boolean
    }

type ContentRange
  = { raw :: String
    , field :: String
    , first :: String
    , last :: String
    }

type NextRange
  = { raw :: String
    , range :: Range
    }

defaultRange :: Range
defaultRange =
  { field: "id"
  , limit: Nothing
  , offset: Nothing
  , descending: false
  }

encodeRange :: Range -> String
encodeRange { field, limit, offset, descending } =
  String.joinWith "; "
    $ Array.catMaybes
        [ Just field
        , ("limit " <> _) <<< show <$> limit
        , ("offset " <> _) <<< show <$> offset
        , Just $ "order " <> bool "asc" "desc" descending
        ]

decodeRange :: String -> Range
decodeRange raw =
  { field: fromMaybe raw $ Array.head xs
  , limit:
      xs
        # Array.findMap \x -> case String.split (wrap " ") x of
            [ "limit", v ] -> Int.fromString v
            _ -> Nothing
  , offset:
      xs
        # Array.findMap \x -> case String.split (wrap " ") x of
            [ "offset", v ] -> Int.fromString v
            _ -> Nothing
  , descending:
      fromMaybe false $ xs
        # Array.findMap \x -> case String.split (wrap " ") x of
            [ "order", "desc" ] -> Just true
            [ "order", "asc" ] -> Just false
            _ -> Nothing
  }
  where
  xs :: Array String
  xs = String.trim <$> String.split (wrap ";") raw

parseContentRange :: String -> Maybe ContentRange
parseContentRange raw =
  Just
    { raw
    , field: fromMaybe "" $ Array.head <<< String.split (wrap " ") =<< Array.head xs
    , first: fromMaybe "" $ Array.head ends
    , last: fromMaybe "" $ Array.last ends
    }
  where
  xs :: Array String
  xs = String.trim <$> String.split (wrap ";") raw

  ends :: Array String
  ends = maybe [] (String.split (wrap "..")) $ Array.last <<< String.split (wrap " ") =<< Array.head xs

parseNextRange :: String -> Maybe NextRange
parseNextRange raw =
  Just
    { raw
    , range: decodeRange raw
    }
