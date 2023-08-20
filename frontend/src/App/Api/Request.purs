module App.Api.Request
  ( BaseUrl(..)
  , RequestMethod(..)
  , login
  , verifyToken
  , readToken
  , writeToken
  , removeToken
  , makeAuthReq
  , makeAuthReqWithHeader
  , makeAuthReqPaginated
  , IgnoreJson(..)
  , RespErr(..)
  , toJsonResp
  ) where

import AppPrelude
import Affjax.RequestBody as RB
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat (ResponseFormat)
import Affjax.ResponseFormat as RF
import Affjax.ResponseHeader (ResponseHeader)
import Affjax.ResponseHeader as ResponseHeader
import Affjax.StatusCode (StatusCode(..))
import Affjax.Web (Error, Request, Response, printError, request)
import App.Api.Endpoint (Endpoint(..), endpointCodec)
import App.Api.Pagination (Pagination, Paginated, ContentRange)
import App.Api.Pagination as Pagination
import App.Api.Token (Token(..))
import App.Data.User (User)
import Data.Argonaut (JsonDecodeError, printJsonDecodeError, (.:))
import Data.Array as Array
import Data.HTTP.Method (Method(..))
import Data.Int as Int
import Prim.Row as Row
import Record as Record
import Routing.Duplex (print)
import Web.HTML (window)
import Web.HTML.Window (localStorage)
import Web.Storage.Storage (getItem, removeItem, setItem)

newtype BaseUrl
  = BaseUrl String

derive instance newtypeBaseUrl :: Newtype BaseUrl _

derive newtype instance showBaseUrl :: Show BaseUrl

data RequestMethod
  = Get
  | Post (Maybe Json)
  | Put (Maybe Json)
  | Delete
  | Head

type RequestOptionsRow
  = ( endpoint :: Endpoint
    , method :: RequestMethod
    | RequestOptionsRowOptional
    )

type RequestOptionsRowOptional
  = ( range :: Maybe Pagination.Range
    )

defaultRequest ::
  forall opts opts' a.
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  BaseUrl -> Maybe Token -> ResponseFormat a -> { | opts } -> Request a
defaultRequest (BaseUrl baseUrl) auth responseFormat opts =
  { method: Left method
  , url: baseUrl <> print endpointCodec endpoint
  , headers: authHeader <> rangeHeader
  , content: RB.json <$> body
  , username: Nothing
  , password: Nothing
  , withCredentials: false
  , responseFormat
  , timeout: Nothing
  }
  where
  def :: Record RequestOptionsRowOptional
  def = { range: Nothing }

  { endpoint, method, range } = Record.merge opts def :: Record RequestOptionsRow

  method /\ body = case method of
    Get -> GET /\ Nothing
    Post b -> POST /\ b
    Put b -> PUT /\ b
    Delete -> DELETE /\ Nothing
    Head -> HEAD /\ Nothing

  authHeader :: Array RequestHeader
  authHeader = maybe [] pure $ auth # map \(Token t) -> RequestHeader "Authorization" ("Bearer " <> t)

  rangeHeader :: Array RequestHeader
  rangeHeader = maybe [] pure $ RequestHeader "Range" <<< Pagination.encodeRange <$> range

type LoginFields
  = { email :: String
    , password :: String
    }

login :: forall m. MonadAff m => BaseUrl -> LoginFields -> m (Either String (Token /\ User))
login baseUrl fields = do
  let
    method = Post $ Just $ encodeJson fields
  requestUser baseUrl { endpoint: Login, method }

requestUser ::
  forall m opts opts'.
  MonadAff m =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  BaseUrl -> { | opts } -> m (Either String (Token /\ User))
requestUser baseUrl opts = do
  let
    req = defaultRequest baseUrl Nothing RF.json opts
  processRequest req parse'
  where
  parse' :: Json -> Either String (Token /\ User)
  parse' body =
    lmap printJsonDecodeError do
      obj <- decodeJson body
      token <- obj .: "token"
      user <- obj .: "user"
      pure $ token /\ user

verifyToken :: forall m. MonadAff m => BaseUrl -> Token -> m (Either String User)
verifyToken baseUrl token = do
  let
    opts = { endpoint: Login, method: Get }
  let
    req = defaultRequest baseUrl (Just token) RF.json opts
  processRequest req parse'
  where
  parse' :: Json -> Either String User
  parse' body =
    lmap printJsonDecodeError do
      obj <- decodeJson body
      user <- obj .: "user"
      pure user

processRequest ::
  forall m a.
  MonadAff m =>
  Request Json ->
  (Json -> Either String a) ->
  m (Either String a)
processRequest req parse = do
  res <- liftAff $ request req
  pure $ processResponse (lmap printError res) parse

processResponse ::
  forall a.
  Either String (Response Json) ->
  (Json -> Either String a) ->
  Either String a
processResponse res parse = do
  body <- rmap _.body res
  case parse body of
    Left msg -> case parseError body of
      Nothing -> Left msg
      Just msg' -> Left msg'
    Right x -> Right x

-- | Parse a `Json` blob as an object with a single field `error_message`.
-- |
-- | These kind of responses are sent from the backend when there is a
-- | HTTP 4XX error.
parseError :: Json -> Maybe String
parseError body = hush $ (_ .: "error_message") =<< decodeJson body

tokenKey :: String
tokenKey = "token"

readToken :: Effect (Maybe Token)
readToken = do
  str <- getItem tokenKey =<< localStorage =<< window
  pure $ map Token str

writeToken :: Token -> Effect Unit
writeToken (Token str) = setItem tokenKey str =<< localStorage =<< window

removeToken :: Effect Unit
removeToken = removeItem tokenKey =<< localStorage =<< window

extractPagination :: Array ResponseHeader -> Pagination
extractPagination hdrs =
  { contentRange
  , nextRange: Pagination.parseNextRange =<< lookup' "next-range"
  , totalCount: Int.fromString =<< lookup' "total-count"
  }
  where
  lookup' :: String -> Maybe String
  lookup' name = ResponseHeader.value <$> Array.find ((_ == name) <<< ResponseHeader.name) hdrs

  contentRange :: Maybe ContentRange
  contentRange = Pagination.parseContentRange =<< lookup' "content-range"

-- | This data type can be used by APIs that don't return anything.
-- |
-- | The important thing about this type is that it has an `DecodeJson`
-- | instance that will always succeed.
-- |
-- | It is possible to use an empty `Record` for APIs that do not return any
-- | JSON (since Affjax converts completely empty responses to empty JSON
-- | objects `{}`), but `IgnoreJson` is more explicit.
data IgnoreJson
  = IgnoreJson

derive instance genericIgnoreJson :: Generic IgnoreJson _

instance showIgnoreJson :: Show IgnoreJson where
  show = genericShow

instance decodeJsonIgnoreJson :: DecodeJson IgnoreJson where
  decodeJson :: Json -> Either JsonDecodeError IgnoreJson
  decodeJson _ = Right IgnoreJson

-- | Possible errors from making an API request to the backend.
data RespErr
  = JsonRespReqErr Error
  | JsonRespUploadErr String
  | JsonRespJsonErr JsonDecodeError
  | JsonRespMissingHeaderErr String
  | JsonRespBadHeaderErr String
  | JsonRespHttpStatusErr StatusCode (Maybe String)

instance showRespErr :: Show RespErr where
  show :: RespErr -> String
  show = case _ of
    JsonRespReqErr err -> "JsonRespReqErr (" <> printError err <> ")"
    JsonRespUploadErr err -> "JsonRespUploadErr (" <> err <> ")"
    JsonRespJsonErr err -> "JsonRespJsonErr (" <> show err <> ")"
    JsonRespMissingHeaderErr key -> "JsonRespMissingHeaderErr (key: " <> key <> ")"
    JsonRespBadHeaderErr key -> "JsonRespBadHeaderErr (key: " <> key <> ")"
    JsonRespHttpStatusErr (StatusCode statusCode) maybeErr ->
      let
        msg = fromMaybe "no error_message" maybeErr
      in
        "JsonRespJsonErr " <> show statusCode <> " (" <> msg <> ")"

-- | Decode a raw `Json` value.  Return `JsonRespJsonErr` when the `Json` can't
-- | be decoded.
toJsonResp :: forall a. DecodeJson a => Json -> Either RespErr a
toJsonResp json = case decodeJson json of
  Left err -> Left $ JsonRespJsonErr err
  Right a -> Right a

makeAuthReqRaw ::
  forall m opts opts' r.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  { | opts } -> m (Either Error (Response Json))
makeAuthReqRaw opts = do
  { baseUrl } <- ask
  token <- liftEffect readToken
  liftAff $ request (defaultRequest baseUrl token RF.json opts)

-- | Make a request to the rails backend.
-- |
-- | Automatically read the authentication token and applies it to the request.
-- |
-- | Automatically JSON-decode the response.
makeAuthReq ::
  forall m opts opts' r a.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  DecodeJson a =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  { | opts } -> m (Either RespErr a)
makeAuthReq opts = do
  affjaxResp <- makeAuthReqRaw opts
  pure $ checkHttpStatusErr affjaxResp >>= _.body >>> toJsonResp

lookupHeader ::
  String ->
  Array ResponseHeader ->
  Maybe String
lookupHeader key hdrs = ResponseHeader.value <$> Array.find ((_ == key) <<< ResponseHeader.name) hdrs

findHeader ::
  forall a.
  DecodeJson a =>
  String ->
  Array ResponseHeader ->
  Either RespErr a
findHeader key hdrs = do
  txt <- note (JsonRespMissingHeaderErr key) $ lookupHeader key hdrs
  note (JsonRespBadHeaderErr key) do
    json <- hush $ jsonParser txt
    hush $ decodeJson json

makeAuthReqWithHeader ::
  forall m opts opts' r a hk hv hr.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  DecodeJson a =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  IsSymbol hk =>
  DecodeJson hv =>
  Row.Cons hk hv ( body :: a ) hr =>
  Row.Lacks hk ( body :: a ) =>
  Proxy hk ->
  { | opts } ->
  m (Either RespErr { | hr })
makeAuthReqWithHeader _ opts = do
  affjaxResp <- makeAuthReqRaw opts
  pure do
    res <- checkHttpStatusErr affjaxResp
    body :: a <- toJsonResp res.body
    v :: hv <- findHeader (reflectSymbol (Proxy :: Proxy hk)) res.headers
    pure $ Record.insert (Proxy :: Proxy hk) v { body }

-- | Handles pagination along with decoding `Json` response.
makeAuthReqPaginated ::
  forall m opts opts' r a.
  MonadAff m =>
  MonadAsk { baseUrl :: BaseUrl | r } m =>
  DecodeJson a =>
  Row.Union opts RequestOptionsRowOptional opts' =>
  Row.Nub opts' RequestOptionsRow =>
  { | opts } -> m (Either RespErr (Paginated a))
makeAuthReqPaginated opts = do
  affjaxResp <- makeAuthReqRaw opts
  pure do
    res <- checkHttpStatusErr affjaxResp
    body <- toJsonResp res.body
    pure { body, pagination: extractPagination res.headers }

-- | Check the `StatusCode` of an Affjax response.
-- |
-- | Return `JsonRespHttpStatusErr` if the `StatusCode` is over 400.
checkHttpStatusErr ::
  Either Error (Response Json) -> Either RespErr (Response Json)
checkHttpStatusErr = lmap JsonRespReqErr >=> f
  where
  f :: Response Json -> Either RespErr (Response Json)
  f resp@{ status: StatusCode statusCode } =
    bool
      (Right resp)
      (Left (JsonRespHttpStatusErr resp.status (parseError resp.body)))
      (statusCode >= 400)
