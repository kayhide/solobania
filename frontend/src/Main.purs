module Main
  ( main
  )
  where

import AppPrelude
import App.Data.DateTime (getTimezone)
import App.Env (LogLevel(..))
import App.View.Router as Router
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Data.String as String
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (element)
import Web.DOM.NonElementParentNode (getElementById)
import Web.DOM.ParentNode (querySelector)
import Web.HTML (window)
import Web.HTML.HTMLDocument (head, toNonElementParentNode)
import Web.HTML.HTMLElement (toParentNode)
import Web.HTML.HTMLMetaElement as Meta
import Web.HTML.Window (document)

main :: Effect Unit
main = do
  baseUrl <-
    readMeta "BASE_URL"
      >>= case _ of
          Nothing -> throw "BASE_URL is not set"
          Just x -> pure $ wrap x
  frontendHost <- case String.split (wrap "//") (unwrap baseUrl) of
    [ _, host ] -> pure $ wrap host
    _ -> throw "BASE_URL is malformed and FRONTEND_HOST cannot be extracted"
  let
    logLevel = Dev
  timezone <- getTimezone
  window
    >>= document
    >>= toNonElementParentNode
    >>> getElementById "app"
    >>= case _ of
        Nothing -> throw "Container element not found."
        Just elm -> do
          router <- Router.make { baseUrl, frontendHost, logLevel, timezone }
          root <- createRoot elm
          renderRoot root $ element router {}

readMeta :: String -> Effect (Maybe String)
readMeta name =
  runMaybeT do
    head' <- MaybeT $ window >>= document >>= head
    meta' <- MaybeT $ toParentNode head' # querySelector (wrap $ "meta[name=" <> name <> "]")
    MaybeT $ traverse Meta.content $ Meta.fromElement meta'
