module App.Data where

import AppPrelude
import Data.Int as Int
import Data.Lens (Lens', _Just, folded, to)
import Data.Lens.Iso.Newtype (_Newtype)
import Data.Newtype (class Newtype)
import Data.String as String
import Prim.Row as Row
import Record as Record

class
  Ord a <= ToId s a | s -> a where
  toId :: s -> a

instance toIdNewtype :: (Ord a, Newtype s { id :: a | r }) => ToId s a where
  toId = _.id <<< unwrap

class Creating s a | s -> a, a -> s where
  _Creating :: Lens' s a

class Updating s a | s -> a, a -> s where
  _Updating :: Lens' s a

-- * Helper functions
updating ::
  forall a id u r r' r''.
  ToId a id =>
  Updating a u =>
  Newtype u { | r } =>
  Row.Union r' r r'' =>
  Row.Nub r'' r =>
  a ->
  { | r' } ->
  id /\ u
updating item attrs = toId item /\ (item ^. _Updating # _Newtype %~ Record.merge attrs)

getNextName :: forall a r. Newtype a { name :: String | r } => String -> Array a -> String
getNextName prefix items = prefix' <> show (maybe 1 (_ + 1) m)
  where
  prefix' :: String
  prefix' = prefix <> " "

  m :: Maybe Int
  m =
    maximum
      $ items
      ^.. folded
      <<< to (String.stripPrefix (wrap prefix') <<< _.name <<< unwrap)
      <<< _Just
      <<< to Int.fromString
      <<< _Just
