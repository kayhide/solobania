module App.View.Agent.SpecsAgent where

import AppViewPrelude
import App.Api.Pagination as Pagination
import App.Api.Specs (api)
import App.Context (context)
import App.Data.Spec (Spec, SpecId)
import App.View.Agent.Utils (useListApi, useShowApi)
import Data.Array as Array
import React.Basic.Hooks as React

type SpecsAgent
  = { items :: Array Spec
    , item :: Maybe Spec
    , lookup :: SpecId -> Maybe Spec
    , totalCount :: Maybe Int
    , isLoading :: Boolean
    , isPartiallyLoaded :: Boolean
    , isNextLoading :: Boolean
    , updateRange :: (Pagination.Range -> Pagination.Range) -> Effect Unit
    , load :: Effect Unit
    , loadNext :: Effect Unit
    , loadOne :: SpecId -> Effect Unit
    , fetch :: SpecId -> Effect Unit
    }

foreign import data UseSpecsAgent :: Type -> Type

useSpecsAgent :: Hook UseSpecsAgent SpecsAgent
useSpecsAgent =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = ctx.store.specs
    ids /\ setIds <- useState ([] :: Array SpecId)
    totalCount /\ setTotalCount <- useState (Nothing :: Maybe Int)
    listApi <- useListApi (Proxy :: _ Spec) (Proxy :: _ "specs") api.list
    showApi <- useShowApi (Proxy :: _ Spec) (Proxy :: _ "specs") api.show
    useEffect unit do
      listApi.setScope unit
      pure $ pure unit
    useEffect listApi.ids do
      setIds $ const listApi.ids
      pure $ pure unit
    useEffect listApi.totalCount do
      setTotalCount $ const listApi.totalCount
      pure $ pure unit
    pure
      { items: Array.catMaybes $ store.lookup <$> ids
      , item: showApi.id >>= store.lookup
      , lookup: store.lookup
      , totalCount
      , isLoading: listApi.isLoading
      , isPartiallyLoaded: listApi.isPartiallyLoaded
      , isNextLoading: listApi.isNextLoading
      , updateRange: listApi.updateRange
      , load: listApi.load
      , loadNext: listApi.loadNext
      , loadOne: showApi.load
      , fetch: showApi.fetch
      }
