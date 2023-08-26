module App.Store where

import AppPrelude
import App.Data (class ToId)
import App.Data.Spec (Spec, SpecId)
import App.Data.Pack (Pack, PackId)
import App.Data.User (User, UserId)
import Prim.Row (class Cons)
import Record as Record

type StoreUnitRow a id
  = ( lookup :: id -> Maybe a
    , put :: Array a -> Effect Unit
    , delete :: Array id -> Effect Unit
    , generation :: Int
    , items :: Map id a
    )

type StoreUnit a id
  = Record (StoreUnitRow a id)

type StoreRow
  = ( users :: StoreUnit User UserId
    , specs :: StoreUnit Spec SpecId
    , packs :: StoreUnit Pack PackId
    )

type Store
  = Record StoreRow

class HasStoreUnit (l :: Symbol) a id | a id -> l, l -> a where
  getStoreUnit :: Proxy l -> Store -> StoreUnit a id

instance hasStoreUnit ::
  ( ToId a id
  , IsSymbol l
  , Cons l (StoreUnit a id) r_rest StoreRow
  ) =>
  HasStoreUnit l a id where
  getStoreUnit = Record.get
