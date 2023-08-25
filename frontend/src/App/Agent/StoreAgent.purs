module App.View.Agent.StoreAgent where

import AppViewPrelude
import App.Store (Store, StoreUnitRow)
import Data.Lens.Index (ix)
import Data.Lens.Record (prop)
import Data.Map as Map
import Prim.Row (class Cons, class Lacks)
import Prim.RowList (class RowToList, RowList, Nil, Cons)
import React.Basic.Hooks as React
import Record as Record

class InitialState (rl :: RowList Type) r | rl -> r where
  initialState' :: Proxy rl -> Record r

instance initialStateNil :: InitialState Nil () where
  initialState' _ = {}

instance initialStateCons ::
  ( IsSymbol l
  , Lacks l r_rest
  , Cons l (Int /\ Map id a) r_rest r
  , InitialState rl_rest r_rest
  ) =>
  InitialState (Cons l su rl_rest) r where
  initialState' _ = Record.insert l (0 /\ Map.empty) $ initialState' (Proxy :: _ rl_rest)
    where
    l = Proxy :: _ l

-- | Automatically creates a state which corresponding to the type of `Store`.
-- For example, if the `Store` has the following type:
--
-- { users :: StoreUnit User UserId
-- , projects :: StoreUnit Project ProjectId
-- }
--
-- it will produce the following state:
--
-- { users: 0 /\ Map.empty
-- , projects: 0 /\ Map.empty
-- }
initialState ::
  forall r r' rl.
  RowToList r rl =>
  InitialState rl r' =>
  Proxy (Record r) -> Record r'
initialState _ = initialState' (Proxy :: _ rl)

class StoreHandler (rl :: RowList Type) r_state r | rl -> r where
  storeHandler' ::
    Proxy rl ->
    (Record r_state /\ ((Record r_state -> Record r_state) -> Effect Unit)) ->
    Record r

instance storeHandlerNil :: StoreHandler Nil a () where
  storeHandler' _ _ = {}

instance storeHandlerCons ::
  ( IsSymbol l
  , Lacks l r_rest
  , Cons l (Record (StoreUnitRow a id)) r_rest r
  , Cons l (Int /\ Map id a) r_state' r_state
  , StoreHandler rl_rest r_state r_rest
  , Ord id
  , Newtype a { id :: id | t }
  ) =>
  StoreHandler (Cons l su rl_rest) r_state r where
  storeHandler' _ accessor@(resources /\ setResources) =
    Record.insert l
      { lookup: \id' -> items ^? ix id'
      , put: \xs -> setResources $ prop l %~ (add 1 *** insertMany xs)
      , delete: \ids -> setResources $ prop l %~ (add 1 *** deleteMany ids)
      , generation
      , items
      }
      $ storeHandler' (Proxy :: _ rl_rest) accessor
    where
    l = Proxy :: _ l

    generation /\ items = Record.get l resources

-- | Automatically instantiates a store with the type of `Store` and
-- a pair of `resources` and `setResources` for the state.
-- `resources` should be like:
--
-- { users :: Int /\ Map UserId User
-- , projects :: Int /\ Map ProjectId Project
-- }
--
-- with this state, it creates an instance of:
--
-- { users :: StoreUnit User UserId
-- . projects :: StoreUnit Project ProjectId
-- }
storeHandler ::
  forall r r' r_state rl.
  RowToList r rl =>
  StoreHandler rl r_state r' =>
  Proxy (Record r) ->
  (Record r_state /\ ((Record r_state -> Record r_state) -> Effect Unit)) ->
  Record r'
storeHandler _ accessor = storeHandler' (Proxy :: _ rl) accessor

foreign import data UseStoreAgent :: Type -> Type

useStoreAgent :: Hook UseStoreAgent Store
useStoreAgent =
  unsafeCoerceHook React.do
    resources /\ setResources <- useState $ initialState (Proxy :: _ Store)
    pure $ storeHandler (Proxy :: _ Store) (resources /\ setResources)

insertMany ::
  forall f a id r.
  Foldable f =>
  Ord id =>
  Newtype a { id :: id | r } =>
  f a -> Map id a -> Map id a
insertMany xs map = foldr (\x -> Map.insert (unwrap x).id x) map xs

deleteMany ::
  forall f a id.
  Foldable f =>
  Ord id =>
  f id -> Map id a -> Map id a
deleteMany ids map = foldr Map.delete map ids
