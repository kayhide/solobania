module App.View.Atom.MenuItem where

import AppViewPrelude
import App.Data.Route (Route, hrefTo)
import Data.Monoid as Monoid
import Data.Nullable as Nullable
import Data.String as String
import Prim.Row as Row
import React.Basic.DOM as R
import Record as Record

data Color
  = Primary
  | Secondary
  | Custom String

type PropsRow
  = (
    | PropsRowOptional
    )

type PropsRowOptional
  = ( className :: String
    , active :: Boolean
    , disabled :: Boolean
    , dst :: Route
    , onClick :: Effect Unit
    , text :: String
    , icon :: String
    , preIcon :: String
    , postIcon :: String
    , content :: JSX
    , color :: Color
    , tall :: Boolean
    , dense :: Boolean
    , bold :: Boolean
    , small :: Boolean
    , luminous :: Boolean
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
      , active: false
      , disabled: false
      , dst: unsafeCoerce unit -- Not used
      , onClick: unsafeCoerce unit -- Not used
      , text: ""
      , icon: ""
      , preIcon: ""
      , postIcon: ""
      , content: mempty
      , color: Primary
      , tall: false
      , dense: false
      , bold: false
      , small: false
      , luminous: false
      } ::
        { | PropsRowOptional }
  let
    { className
    , active
    , disabled
    , text
    , icon
    , preIcon
    , postIcon
    , content
    , color
    , tall
    , dense
    , bold
    , small
    , luminous
    } = Record.merge props def :: Props

    dst = Nullable.toMaybe (unsafeCoerce props).dst

    onClick = Nullable.toMaybe (unsafeCoerce props).onClick

    static = isNothing dst && isNothing onClick

    body =
      [ Monoid.guard (not $ String.null preIcon) $ R.i { className: preIcon <> " mr-3" }
      , R.text $ unemptify text
      , Monoid.guard (not $ String.null icon) $ R.i { className: icon }
      , content
      , Monoid.guard (not $ String.null postIcon) $ R.i { className: postIcon <> " ml-3" }
      ]

    colorClass = case color of
      Primary -> "text-primary-700 border-primary-700"
      Secondary -> "text-secondary-700 border-secondary-700"
      Custom x' -> "text-" <> x'

    paddingClass = case dense, tall of
      false, false -> "px-4 py-2"
      false, true -> "p-4"
      true, false -> "px-2 py-1"
      true, true -> "p-2"

    allClass =
      "relative self-stretch flex items-center transition duration-200"
        <> Monoid.guard bold " font-semibold"
        <> Monoid.guard small " text-sm"
        <> Monoid.guard disabled " opacity-50 cursor-default"
        <> Monoid.guard luminous " filter hover:drop-shadow hover:brightness-125"
        <> Monoid.guard (not disabled && not static) " underline-effect"
        <> Monoid.guard (not disabled && not active && not static && not luminous) " opacity-75 hover:opacity-100 hover:font-semibold"
        <> bool "" " active" active
        <> (" " <> colorClass)
        <> (" " <> paddingClass)
        <> (mmap (append " ") className)
  case dst, onClick, disabled of
    Nothing, Nothing, _ ->
      R.div
        { className: allClass
        , children: body
        }
    Nothing, Just onClick', false ->
      R.button
        { className: allClass
        , onClick: capture_ onClick'
        , children: body
        }
    Just dst', _, false ->
      R.a
        { className: allClass
        , href: hrefTo dst'
        , children: body
        }
    _, _, true ->
      R.button
        { className: allClass
        , children: body
        }
