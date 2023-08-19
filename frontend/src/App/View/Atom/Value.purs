module App.View.Atom.Value where

import AppViewPrelude
import Prim.Row as Row
import React.Basic.DOM as R
import Data.Nullable as Nullable
import Record as Record

data Color
  = Primary
  | Secondary
  | Success
  | Warning
  | Danger
  | Custom String

data Justify
  = JustifyCenter
  | JustifyLeft
  | JustifyRight

type PropsRow
  = (
    | PropsRowOptional
    )

type PropsRowOptional
  = ( className :: String
    , text :: String
    , color :: Color
    , fill :: Boolean
    , active:: Boolean
    , dense :: Boolean
    , small :: Boolean
    , large :: Boolean
    , translucent :: Boolean
    , justify :: Justify
    , onClick :: Effect Unit
    )

type Props
  = { | PropsRow }

render ::
  forall props props'.
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render props = do
  let
    def =
      { className: ""
      , text: ""
      , color: Primary
      , fill: false
      , active: false
      , dense: false
      , small: false
      , large: false
      , translucent: false
      , justify: unsafeCoerce unit
      , onClick: unsafeCoerce unit
      } ::
        { | PropsRowOptional }
  let
    { className
    , text
    , color
    , fill
    , active
    , dense
    , small
    , translucent
    , large
    } = Record.merge props def :: Props

    justify = Nullable.toMaybe (unsafeCoerce props).justify

    justifyClass =
      fromMaybe ""
        $ justify
        <#> case _ of
            JustifyCenter -> "text-center"
            JustifyLeft -> "text-left"
            JustifyRight -> "text-right"

    onClick = Nullable.toMaybe (unsafeCoerce props).onClick

    colorClass =
      let
        x = case color of
          Primary -> "primary"
          Secondary -> "secondary"
          Success -> "success"
          Warning -> "warning"
          Danger -> "danger"
          Custom x' -> x'
      in
        case fill of
          false ->
            ("text-" <> x <> "-dark")
              <> " border-transparent"
              <> (bool "" (" bg-" <> x <> "-lighter") active)
          true ->
            "text-white"
              <> (" border-" <> x)
              <> (bool (" bg-" <> x) (" bg-" <> x <> "-dark") active)

    className' =
      "text-ellipsis overflow-hidden emptiable-text"
        <> bool " px-3 py-2" " px-2 py-1" dense
        <> bool "" " text-sm" small
        <> bool "" " text-xl" large
        <> bool "" " bg-opacity-75" translucent
        <> mmap (append " ") justifyClass
        <> bool "" " cursor-pointer" (isJust onClick)
        <> (" " <> colorClass)
        <> mmap (append " ") className
  case onClick of
    Nothing ->
      R.div
        { className: className'
        , children: pure $ R.text text
        }
    Just onClick' ->
      R.div
        { className: className'
        , onClick: capture_ onClick'
        , children: pure $ R.text text
        }
