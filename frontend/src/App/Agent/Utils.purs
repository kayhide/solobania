module App.View.Agent.Utils
  ( ApiCall
  , runApi
  , runApiWithErrorHandler
  , runApiMay
  , onError
  -- ListApi
  , ListApiCall
  , UseListApi
  , useListApi
  -- ShowApi
  , ShowApiCall
  , UseShowApi
  , useShowApi
  -- CreateApi
  , CreateApiCall
  , UseCreateApi
  , useCreateApi
  -- CreateManyApi
  , CreateManyApiCall
  , UseCreateManyApi
  , useCreateManyApi
  -- UpdateApi
  , UpdateApiCall
  , UseUpdateApi
  , useUpdateApi
  -- DestroyApi
  , DestroyApiCall
  , UseDestroyApi
  , useDestroyApi
  -- CastApi
  , CastApiCall
  , UseCastApi
  , useCastApi
  ) where

import AppViewPrelude
import Affjax.StatusCode (StatusCode(..))
import App.Api.Pagination (Paginated, Pagination)
import App.Api.Pagination as Pagination
import App.Api.Request (IgnoreJson, RespErr(..))
import App.Context (ContextRecord, context)
import App.Data (class ToId, toId)
import App.Env (Env)
import App.Notification (Notifier)
import App.Store (class HasStoreUnit, StoreUnit, getStoreUnit)
import App.View.Helper.Sequential (useSequential)
import React.Basic.Hooks as React

type ApiCall m a
  = ReaderT Env m (Either RespErr a)

-- | Automatically decodes the response JSON.
-- | Run a callback after accessing the API and there were no errors.
-- | Call an error handler for any errors with
-- | either accessing the API or decoded the returned JSON.
runApiWithErrorHandler ::
  forall m a.
  MonadAff m =>
  ContextRecord ->
  ApiCall m a ->
  (RespErr -> m Unit) ->
  (a -> m Unit) ->
  m Unit
runApiWithErrorHandler { env } apiCall onError' onSuccess' =
  runReaderT apiCall env
    >>= either onError' onSuccess'

-- | Call `runApiWithErrorHandler` with a default error handler which
-- | passes an error to the notifier given by the context.
runApi ::
  forall m a.
  MonadAff m =>
  ContextRecord ->
  ApiCall m a ->
  (a -> m Unit) ->
  m Unit
runApi ctx apiCall callback = runApiWithErrorHandler ctx apiCall (onError ctx) callback

-- | Unlike `runApi`, it returns Maybe value insetad of running a callback function.
-- | It returns a `Nothing` in case of any failure, and a `Just` if succeeded.
runApiMay ::
  forall m a.
  MonadAff m =>
  ContextRecord ->
  ApiCall m a ->
  m (Maybe a)
runApiMay ctx@{ env } apiCall =
  runReaderT apiCall env
    >>= case _ of
        Left err -> do
          onError ctx err
          pure Nothing
        Right a -> pure $ Just a

onError :: forall m r. MonadEffect m => { notifier :: Notifier | r } -> RespErr -> m Unit
onError context = liftEffect <<< context.notifier.error <<< showError
  where
  showError :: RespErr -> String
  showError err = "Error occurred when trying to access the API: " <> show err

-- | ListApi hook
type ListApi id scope
  = { ids :: Array id
    , totalCount :: Maybe Int
    , isLoading :: Boolean
    , isLoaded :: Boolean
    , isPartiallyLoaded :: Boolean
    , isNextLoading :: Boolean
    , updateRange :: (Pagination.Range -> Pagination.Range) -> Effect Unit
    , setScope :: scope -> Effect Unit
    , load :: Effect Unit
    , loadNext :: Effect Unit
    , unload :: Effect Unit
    }

type ListApiCall a scope
  = scope -> Maybe Pagination.Range -> ApiCall Aff (Paginated (Array a))

foreign import data UseListApi :: Type -> Type

useListApi ::
  forall a id scope l.
  Eq scope =>
  ToId a id =>
  HasStoreUnit l a id =>
  Proxy a ->
  Proxy l ->
  ListApiCall a scope ->
  Hook UseListApi (ListApi id scope)
useListApi _ label api =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = getStoreUnit label ctx.store :: StoreUnit a id
    ids /\ setIds <- useState ([] :: Array id)
    isLoading /\ setIsLoading <- useState false
    isNextLoading /\ setIsNextLoading <- useState false
    loadingRange /\ setLoadingRange <- useState Pagination.defaultRange
    pagination /\ setPagination <- useState (Nothing :: Maybe Pagination)
    scope /\ setScope <- useState (Nothing :: Maybe scope)
    useAff (scope /\ isLoading) do
      for_ scope \scope' -> do
        when isLoading do
          runApi ctx (api scope' $ Just loadingRange) \{ body: items, pagination: pagination' } ->
            liftEffect do
              store.put items
              setIds $ const $ toId <$> items
              setPagination $ const $ Just pagination'
        liftEffect $ setIsLoading $ const false
    useAff (scope /\ isNextLoading) do
      for_ scope \scope' -> do
        when isNextLoading do
          when (not isLoading) do
            for_ (pagination >>= _.nextRange) \{ range } -> do
              runApi ctx (api scope' $ Just range) \{ body: items, pagination: pagination' } ->
                liftEffect do
                  store.put items
                  setIds (_ <> (toId <$> items))
                  setPagination $ const $ Just pagination'
        liftEffect $ setIsNextLoading $ const false
    pure
      { ids
      , totalCount: _.totalCount =<< pagination
      , isLoading
      , isLoaded: isJust pagination
      , isPartiallyLoaded: maybe false (isJust <<< _.nextRange) pagination
      , isNextLoading
      , updateRange: setLoadingRange
      , setScope: setScope <<< const <<< Just
      , load: setIsLoading $ const true
      , loadNext: setIsNextLoading $ const true
      , unload:
          do
            setIsLoading $ const false
            setIsNextLoading $ const false
            setIds $ const []
      }

-- | ShowApi hook
type ShowApi id
  = { id :: Maybe id
    , isLoading :: Boolean
    , load :: id -> Effect Unit
    , fetch :: id -> Effect Unit
    , onNotFound :: (id -> Effect Unit) -> Effect Unit
    }

type ShowApiCall a id
  = id -> ApiCall Aff a

foreign import data UseShowApi :: Type -> Type

useShowApi ::
  forall a id l.
  ToId a id =>
  HasStoreUnit l a id =>
  Proxy a ->
  Proxy l ->
  ShowApiCall a id ->
  Hook UseShowApi (ShowApi id)
useShowApi _ label api =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = getStoreUnit label ctx.store :: StoreUnit a id
    id /\ setId <- useState (Nothing :: Maybe id)
    seq <- useSequential
    onNotFound /\ setOnNotFound <- useState (const $ pure unit :: id -> Effect Unit)
    useEffect unit do
      setOnNotFound $ const $ \_ -> onError ctx (JsonRespHttpStatusErr (StatusCode 404) Nothing)
      seq.setAction \id' -> do
        runApiWithErrorHandler ctx (api id')
          ( \err ->
              liftEffect do
                case err of
                  JsonRespHttpStatusErr (StatusCode 404) _ -> onNotFound id'
                  _ -> onError ctx err
                store.delete $ pure id'
                setId $ const Nothing
          )
          ( \item ->
              liftEffect do
                store.put $ pure item
                setId $ const $ Just id'
          )
      pure $ pure unit
    pure
      { id
      , isLoading: seq.isRunning
      , load: seq.push
      , fetch:
          \id' -> do
            case store.lookup id' of
              Nothing -> seq.push id'
              Just _ -> setId $ const $ Just id'
      , onNotFound: setOnNotFound <<< const
      }

-- | CreateApi hook
type CreateApi id creating scope
  = { id :: Maybe id
    , isSubmitting :: Boolean
    , setScope :: scope -> Effect Unit
    , create :: creating -> Effect Unit
    , onRequestEntityTooLarge :: Effect Unit -> Effect Unit
    }

type CreateApiCall a creating scope
  = scope -> creating -> ApiCall Aff a

foreign import data UseCreateApi :: Type -> Type

useCreateApi ::
  forall a id creating scope l.
  ToId a id =>
  Eq creating =>
  HasStoreUnit l a id =>
  Eq scope =>
  Proxy a ->
  Proxy l ->
  CreateApiCall a creating scope ->
  Hook UseCreateApi (CreateApi id creating scope)
useCreateApi _ label api =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = getStoreUnit label ctx.store :: StoreUnit a id
    id /\ setId <- useState (Nothing :: Maybe id)
    scope /\ setScope <- useState (Nothing :: Maybe scope)
    seq <- useSequential
    onRequestEntityTooLarge /\ setOnRequestEntityTooLarge <- useState (pure unit)
    useEffect unit do
      setOnRequestEntityTooLarge $ const $ onError ctx (JsonRespHttpStatusErr (StatusCode 413) Nothing)
      pure $ pure unit
    useEffect (scope /\ (unsafeCoerce onRequestEntityTooLarge :: Unit)) do
      setId $ const Nothing
      seq.clear
      case scope of
        Nothing -> do
          seq.setAction $ const $ pure unit
        Just scope' -> do
          seq.setAction \creating' -> do
            runApiWithErrorHandler ctx (api scope' creating')
              ( \err ->
                  liftEffect do
                    case err of
                      JsonRespHttpStatusErr (StatusCode 413) _ -> onRequestEntityTooLarge
                      _ -> onError ctx err
                    setId $ const Nothing
              )
              ( \item ->
                  liftEffect do
                    store.put $ pure item
                    setId $ const $ Just $ toId item
              )
      pure $ pure unit
    pure
      { id
      , isSubmitting: seq.isRunning
      , setScope: setScope <<< const <<< Just
      , create: seq.push
      , onRequestEntityTooLarge: setOnRequestEntityTooLarge <<< const
      }

-- | CreateManyApi hook
type CreateManyApi id creating scope
  = { ids :: Array id
    , isSubmitting :: Boolean
    , setScope :: scope -> Effect Unit
    , create :: creating -> Effect Unit
    }

type CreateManyApiCall a creating scope
  = scope -> creating -> ApiCall Aff (Array a)

foreign import data UseCreateManyApi :: Type -> Type

useCreateManyApi ::
  forall a id creating scope l.
  ToId a id =>
  Eq creating =>
  HasStoreUnit l a id =>
  Eq scope =>
  Proxy a ->
  Proxy l ->
  CreateManyApiCall a creating scope ->
  Hook UseCreateManyApi (CreateManyApi id creating scope)
useCreateManyApi _ label api =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = getStoreUnit label ctx.store :: StoreUnit a id
    ids /\ setIds <- useState ([] :: Array id)
    scope /\ setScope <- useState (Nothing :: Maybe scope)
    seq <- useSequential
    useEffect scope do
      setIds $ const []
      seq.clear
      case scope of
        Nothing -> do
          seq.setAction $ const $ pure unit
        Just scope' -> do
          seq.setAction \creating' -> do
            runApi ctx (api scope' creating') \items ->
              liftEffect do
                store.put items
                setIds $ const $ toId <$> items
            liftEffect do
              setIds $ const []
      pure $ pure unit
    pure
      { ids
      , isSubmitting: seq.isRunning
      , setScope: setScope <<< const <<< Just
      , create: seq.push
      }

-- | UpdateApi hook
type UpdateApi id updating
  = { id :: Maybe id
    , isSubmitting :: Boolean
    , update :: id /\ updating -> Effect Unit
    }

type UpdateApiCall a id updating
  = id -> updating -> ApiCall Aff a

foreign import data UseUpdateApi :: Type -> Type

useUpdateApi ::
  forall a id updating l.
  ToId a id =>
  Eq updating =>
  HasStoreUnit l a id =>
  Proxy a ->
  Proxy l ->
  UpdateApiCall a id updating ->
  Hook UseUpdateApi (UpdateApi id updating)
useUpdateApi _ label api =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = getStoreUnit label ctx.store :: StoreUnit a id
    id /\ setId <- useState (Nothing :: Maybe id)
    seq <- useSequential
    useEffect unit do
      seq.setAction \(id' /\ updating') -> do
        runApi ctx (api id' updating') \item ->
          liftEffect do
            store.put $ pure item
            setId $ const $ Just id'
        liftEffect do
          setId $ const Nothing
      pure $ pure unit
    pure
      { id
      , isSubmitting: seq.isRunning
      , update: seq.push
      }

-- | DestroyApi hook
type DestroyApi id
  = { id :: Maybe id
    , isSubmitting :: Boolean
    , destroy :: id -> Effect Unit
    }

type DestroyApiCall id
  = id -> ApiCall Aff IgnoreJson

foreign import data UseDestroyApi :: Type -> Type

useDestroyApi ::
  forall a id l.
  ToId a id =>
  HasStoreUnit l a id =>
  Proxy a ->
  Proxy l ->
  DestroyApiCall id ->
  Hook UseDestroyApi (DestroyApi id)
useDestroyApi _ label api =
  unsafeCoerceHook React.do
    ctx <- useContext context
    let
      store = getStoreUnit label ctx.store :: StoreUnit a id
    id /\ setId <- useState (Nothing :: Maybe id)
    seq <- useSequential
    useEffect unit do
      seq.setAction \id' -> do
        runApi ctx (api id') \_ ->
          liftEffect do
            store.delete $ pure id'
            setId $ const $ Just id'
        liftEffect do
          setId $ const Nothing
      pure $ pure unit
    pure
      { id
      , isSubmitting: seq.isRunning
      , destroy: seq.push
      }

-- | CastApi hook
type CastApi id scope
  = { id :: Maybe id
    , isSubmitting :: Boolean
    , setScope :: scope -> Effect Unit
    , cast :: id -> Effect Unit
    }

type CastApiCall id scope
  = scope -> id -> ApiCall Aff IgnoreJson

foreign import data UseCastApi :: Type -> Type

useCastApi ::
  forall a id scope.
  ToId a id =>
  Eq scope =>
  Proxy a ->
  CastApiCall id scope ->
  Hook UseCastApi (CastApi id scope)
useCastApi _ api =
  unsafeCoerceHook React.do
    ctx <- useContext context
    id /\ setId <- useState (Nothing :: Maybe id)
    scope /\ setScope <- useState (Nothing :: Maybe scope)
    seq <- useSequential
    useEffect scope do
      seq.clear
      seq.setAction \id' -> do
        for_ scope \scope' -> do
          runApi ctx (api scope' id') \_ ->
            liftEffect do
              setId $ const $ Just id'
          liftEffect do
            setId $ const Nothing
      pure $ pure unit
    pure
      { id
      , isSubmitting: seq.isRunning
      , setScope: setScope <<< const <<< Just
      , cast: seq.push
      }
