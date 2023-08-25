module App.View.Atom.Button where

import AppViewPrelude
import Data.Monoid as Monoid
import Data.Nullable as Nullable
import Data.String as String
import App.View.Sl as Sl
import Prim.Row as Row
import React.Basic.DOM as R
import Record as Record

data Variant
  = Default
  | Primary
  | Success
  | Neutral
  | Warning
  | Danger

data Sizing
  = Small
  | Medium
  | Large

type PropsRow
  = (
    | PropsRowOptional
    )

type PropsRowOptional
  = ( disabled :: Boolean
    , loading :: Boolean
    , href :: String
    , onClick :: Effect Unit
    , text :: String
    , icon :: String
    , preIcon :: String
    , postIcon :: String
    , content :: JSX
    , variant :: Variant
    , fill :: Boolean
    , bare :: Boolean
    , active :: Boolean
    , bold :: Boolean
    , dense :: Boolean
    , size :: Sizing
    , small :: Boolean
    , translucent :: Boolean
    , width :: Sizing
    , height :: Sizing
    , fullWidth :: Boolean
    , fullHeight :: Boolean
    , textLeft :: Boolean
    , textRight :: Boolean
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
      { disabled: false
      , loading: false
      , href: unsafeCoerce unit
      , onClick: pure unit
      , text: ""
      , icon: ""
      , preIcon: ""
      , postIcon: ""
      , content: mempty
      , variant: Default
      , fill: false
      , bare: false
      , active: false
      , bold: true
      , dense: false
      , size: Medium
      , small: false
      , translucent: false
      , width: unsafeCoerce unit
      , height: unsafeCoerce unit
      , fullWidth: false
      , fullHeight: false
      , textLeft: false
      , textRight: false
      } ::
        { | PropsRowOptional }
  let
    { onClick
    , disabled
    , loading
    , text
    , icon
    , preIcon
    , postIcon
    , content
    , variant
    , fill
    , bare
    , active
    , bold
    , dense
    , size
    , small
    , translucent
    , fullHeight
    , fullWidth
    , textLeft
    , textRight
    } = Record.merge props def :: Props

    href = Nullable.toMaybe (unsafeCoerce props).href

    width = Nullable.toMaybe (unsafeCoerce props).width

    height = Nullable.toMaybe (unsafeCoerce props).height

    body =
      [ Monoid.guard (not $ String.null preIcon) $ R.i { slot: "prefix", className: preIcon }
      , R.text $ unemptify text
      , Monoid.guard (not $ String.null icon) $ R.i { className: icon }
      , content
      , Monoid.guard (not $ String.null postIcon) $ R.i { slot: "suffix", className: postIcon }
      ]

    variant' = case bare, variant of
      false, Default -> "default"
      false, Primary -> "primary"
      false, Success -> "success"
      false, Neutral -> "neutral"
      false, Warning -> "warning"
      false, Danger -> "danger"
      true, _ -> "text"

    size' = case size of
      Small -> "small"
      Medium -> "medium"
      Large -> "large"

    widthClass = case fullWidth, width of
      false, Nothing -> ""
      false, Just Small -> "w-16"
      false, Just Medium -> "w-32"
      false, Just Large -> "w-64"
      true, _ -> "w-full"

    heightClass = case fullHeight, height of
      false, Nothing -> ""
      false, Just Small -> "h-16"
      false, Just Medium -> "h-32"
      false, Just Large -> "h-64"
      true, _ -> "h-full"

    buttonClass =
      bool "" " font-bold" bold
        <> bool "" " bg-opacity-75" translucent
        <> bool "" " text-left" textLeft
        <> bool "" " text-right" textRight
        <> mmap (append " ") widthClass
        <> mmap (append " ") heightClass
  Sl.button
    { className: buttonClass
    , variant: variant'
    , size: size'
    , href: toNullable href
    , outline: not fill
    , loading
    , disabled
    , onClick: capture_ onClick
    , children: body
    }
