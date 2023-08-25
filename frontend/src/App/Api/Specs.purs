module App.Api.Specs where

import AppPrelude
import App.Api.Endpoint as Endpoint
import App.Api.Pagination (Paginated)
import App.Api.Pagination as Pagination
import App.Api.Request (BaseUrl, RequestMethod(..), RespErr, makeAuthReq, makeAuthReqPaginated)
import App.Data.Spec (Spec, SpecId)

api ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  { list :: Unit -> Maybe Pagination.Range -> m (Either RespErr (Paginated (Array Spec)))
  , show :: SpecId -> m (Either RespErr Spec)
  }
api =
  { list:
      \_ range ->
        makeAuthReqPaginated
          { endpoint: Endpoint.Specs
          , method: Get
          , range
          }
  , show:
      \id' ->
        makeAuthReq
          { endpoint: Endpoint.Spec id'
          , method: Get
          }
  }
