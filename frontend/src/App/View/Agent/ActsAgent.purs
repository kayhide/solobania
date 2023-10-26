module App.View.Agent.ActsAgent where

import AppViewPrelude
import App.Data.Id (PackId, ProblemId)
import App.Api.Pagination as Pagination
import App.Api.Acts (api)
import App.Context (context)
import App.Data.Act (Act, ActId, CreatingAct, UpdatingAct)
import App.View.Agent.Utils (useListApi, useShowApi, useCreateApi, useUpdateApi)
import Data.Array as Array
import React.Basic.Hooks as React

type ActsAgent
  = { items :: Array Act
    , item :: Maybe Act
    , createdItem :: Maybe Act
    , lookup :: ActId -> Maybe Act
    , totalCount :: Maybe Int
    , isLoading :: Boolean
    , isPartiallyLoaded :: Boolean
    , isNextLoading :: Boolean
    , isSubmitting :: Boolean
    , setProblemId :: ProblemId -> Effect Unit
    , setPackId :: PackId -> Effect Unit
    , updateRange :: (Pagination.Range -> Pagination.Range) -> Effect Unit
    , load :: Effect Unit
    , loadOne :: ActId -> Effect Unit
    , loadNext :: Effect Unit
    , fetch :: ActId -> Effect Unit
    , create :: CreatingAct -> Effect Unit
    , update :: ActId /\ UpdatingAct -> Effect Unit
    }

foreign import data UseActsAgent :: Type -> Type

useActsAgent :: Hook UseActsAgent ActsAgent
useActsAgent =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = ctx.store.acts
    ids /\ setIds <- useState ([] :: Array ActId)
    totalCount /\ setTotalCount <- useState (Nothing :: Maybe Int)
    listApi <- useListApi (Proxy :: _ Act) (Proxy :: _ "acts") api.list
    showApi <- useShowApi (Proxy :: _ Act) (Proxy :: _ "acts") api.show
    createApi <- useCreateApi (Proxy :: _ Act) (Proxy :: _ "acts") api.create
    updateApi <- useUpdateApi (Proxy :: _ Act) (Proxy :: _ "acts") api.update
    useEffect unit do
      listApi.setScope Nothing
      pure $ pure unit
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
      , isSubmitting: createApi.isSubmitting || updateApi.isSubmitting
      , setProblemId:
          \id' -> do
            createApi.setScope id'
      , setPackId:
          \id' -> do
            listApi.setScope $ Just id'
      , updateRange: listApi.updateRange
      , load: listApi.load
      , loadNext: listApi.loadNext
      , loadOne: showApi.load
      , fetch: showApi.fetch
      , create: createApi.create
      , update: updateApi.update
      }
