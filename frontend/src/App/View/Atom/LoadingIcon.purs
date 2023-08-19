module App.View.Atom.LoadingIcon where

import AppViewPrelude
import Prim.Row as Row
import React.Basic.DOM as R
import Record as Record

type PropsRow
  = (
    | PropsRowOptional
    )

type PropsRowOptional
  = ( className :: String
    , active :: Boolean
    , icon :: String
    , size :: Size
    , full :: Boolean
    , overlay :: Boolean
    )

type Props
  = { | PropsRow }

data Size
  = Medium
  | Large
  | Huge

render ::
  forall props props'.
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render props = do
  let
    def =
      { className: ""
      , active: false
      , icon: "fas fa-spinner fa-pulse"
      , size: Medium
      , full: true
      , overlay: true
      } ::
        { | PropsRowOptional }
  let
    { icon
    , className
    , active
    , size
    , full
    , overlay
    } = Record.merge props def :: Props
  let
    sizeClassName = case size of
      Medium -> ""
      Large -> "fa-3x"
      Huge -> "fa-5x"
  R.span
    { className:
        "text-text-secondary text-center pointer-events-none select-none transition duration-500"
          <> bool " opacity-0" "" active
          <> bool "" " top-0 mt-20 absolute z-10" overlay
          <> bool "" " w-full" full
          <> (mmap (append " ") className)
    , children: pure $ R.i { className: icon <> mmap (append " ") sizeClassName }
    }
