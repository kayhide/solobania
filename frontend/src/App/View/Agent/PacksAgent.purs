module App.View.Agent.PacksAgent where

import AppViewPrelude
import App.Api.Pagination as Pagination
import App.Api.Packs (api)
import App.Context (context)
import App.Data.Pack (Pack, PackId, CreatingPack)
import App.Data.Spec (SpecId)
import Data.Array as Array
import React.Basic.Hooks as React
import App.View.Agent.Utils (useListApi, useShowApi, useCreateApi)

type PacksAgent
  = { items :: Array Pack
    , item :: Maybe Pack
    , createdItem :: Maybe Pack
    , lookup :: PackId -> Maybe Pack
    , totalCount :: Maybe Int
    , isLoading :: Boolean
    , isPartiallyLoaded :: Boolean
    , isNextLoading :: Boolean
    , isSubmitting :: Boolean
    , setSpecId :: SpecId -> Effect Unit
    , updateRange :: (Pagination.Range -> Pagination.Range) -> Effect Unit
    , load :: Effect Unit
    , loadNext :: Effect Unit
    , loadOne :: PackId -> Effect Unit
    , fetch :: PackId -> Effect Unit
    , create :: CreatingPack -> Effect Unit
    }

foreign import data UsePacksAgent :: Type -> Type

usePacksAgent :: Hook UsePacksAgent PacksAgent
usePacksAgent =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = ctx.store.packs
    ids /\ setIds <- useState ([] :: Array PackId)
    totalCount /\ setTotalCount <- useState (Nothing :: Maybe Int)
    listApi <- useListApi (Proxy :: _ Pack) (Proxy :: _ "packs") api.list
    showApi <- useShowApi (Proxy :: _ Pack) (Proxy :: _ "packs") api.show
    createApi <- useCreateApi (Proxy :: _ Pack) (Proxy :: _ "packs") api.create
    useEffect listApi.ids do
      setIds $ const listApi.ids
      pure $ pure unit
    useEffect listApi.totalCount do
      setTotalCount $ const listApi.totalCount
      pure $ pure unit
    useEffect createApi.id do
      for_ createApi.id \id' -> do
        setIds $ Array.cons id'
        setTotalCount $ map (_ + 1)
      pure $ pure unit
    pure
      { items: Array.catMaybes $ store.lookup <$> ids
      , item: showApi.id >>= store.lookup
      , createdItem: createApi.id >>= store.lookup
      , lookup: store.lookup
      , totalCount
      , isLoading: listApi.isLoading
      , isPartiallyLoaded: listApi.isPartiallyLoaded
      , isNextLoading: listApi.isNextLoading
      , isSubmitting: createApi.isSubmitting
      , setSpecId:
          \id' -> do
            listApi.setScope id'
            createApi.setScope id'
      , updateRange: listApi.updateRange
      , load: listApi.load
      , loadNext: listApi.loadNext
      , loadOne: showApi.load
      , fetch: showApi.fetch
      , create: createApi.create
      }
