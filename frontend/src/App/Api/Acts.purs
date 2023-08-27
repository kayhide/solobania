module App.Api.Acts where

import AppPrelude
import App.Api.Endpoint as Endpoint
import App.Api.Pagination (Paginated)
import App.Api.Pagination as Pagination
import App.Api.Request (BaseUrl, RequestMethod(..), RespErr, makeAuthReq, makeAuthReqPaginated)
import App.Data.Id (ProblemId)
import App.Data.Act (Act, ActId, CreatingAct, UpdatingAct)

api ::
  forall m r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  { list :: Unit -> Maybe Pagination.Range -> m (Either RespErr (Paginated (Array Act)))
  , show :: ActId -> m (Either RespErr Act)
  , create :: ProblemId -> CreatingAct -> m (Either RespErr Act)
  , update :: ActId -> UpdatingAct -> m (Either RespErr Act)
  }
api =
  { list:
      \_ range ->
        makeAuthReqPaginated
          { endpoint: Endpoint.Acts
          , method: Get
          , range
          }
  , show:
      \id' ->
        makeAuthReq
          { endpoint: Endpoint.Act id'
          , method: Get
          }
  , create:
      \problemId creating -> do
        makeAuthReq
          { endpoint: Endpoint.ProblemActs problemId
          , method: Post $ Just $ encodeJson creating
          }
  , update:
      \id' updating ->
        makeAuthReq
          { endpoint: Endpoint.Act id'
          , method: Put $ Just $ encodeJson updating
          }
  }
