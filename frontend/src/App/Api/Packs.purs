module App.Api.Packs where

import AppPrelude
import App.Api.Endpoint as Endpoint
import App.Api.Pagination (Paginated)
import App.Api.Pagination as Pagination
import App.Api.Request (BaseUrl, RequestMethod(..), RespErr, makeAuthReq, makeAuthReqPaginated)
import App.Data.Pack (Pack, PackId, CreatingPack)
import App.Data.Spec (SpecId)

api ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  { list :: SpecId -> Maybe Pagination.Range -> m (Either RespErr (Paginated (Array Pack)))
  , show :: PackId -> m (Either RespErr Pack)
  , create :: SpecId -> CreatingPack -> m (Either RespErr Pack)
  }
api =
  { list:
      \specId range ->
        makeAuthReqPaginated
          { endpoint: Endpoint.SpecPacks specId
          , method: Get
          , range
          }
  , show:
      \id' ->
        makeAuthReq
          { endpoint: Endpoint.Pack id'
          , method: Get
          }
  , create:
      \specId creating ->
        makeAuthReq
          { endpoint: Endpoint.SpecPacks specId
          , method: Post $ Just $ encodeJson creating
          }
  }
