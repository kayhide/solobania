module App.View.Atom.Button where

import AppViewPrelude
import Data.Monoid as Monoid
import Data.Nullable as Nullable
import Data.String as String
import Prim.Row as Row
import React.Basic.DOM as R
import Record as Record

data Color
  = Primary
  | Secondary
  | Success
  | Warning
  | Danger
  | Custom String

data Sizing
  = Small
  | Medium
  | Large
  | Full

type PropsRow
  = (
    | PropsRowOptional
    )

type PropsRowOptional
  = ( type_ :: String
    , disabled :: Boolean
    , loading :: Boolean
    , href :: String
    , onClick :: Effect Unit
    , text :: String
    , icon :: String
    , preIcon :: String
    , postIcon :: String
    , content :: JSX
    , color :: Color
    , fill :: Boolean
    , bare :: Boolean
    , active :: Boolean
    , bold :: Boolean
    , dense :: Boolean
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
      { type_: "button"
      , disabled: false
      , loading: unsafeCoerce unit
      , href: unsafeCoerce unit
      , onClick: pure unit
      , text: ""
      , icon: ""
      , preIcon: ""
      , postIcon: ""
      , content: mempty
      , color: Primary
      , fill: false
      , bare: false
      , active: false
      , bold: true
      , dense: false
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
    { type_
    , onClick
    , disabled
    , text
    , icon
    , preIcon
    , postIcon
    , content
    , color
    , fill
    , bare
    , active
    , bold
    , dense
    , small
    , translucent
    , fullHeight
    , fullWidth
    , textLeft
    , textRight
    } = Record.merge props def :: Props

    loading = Nullable.toMaybe (unsafeCoerce props).loading

    href = Nullable.toMaybe (unsafeCoerce props).href

    width = Nullable.toMaybe (unsafeCoerce props).width

    height = Nullable.toMaybe (unsafeCoerce props).height

    body =
      [ Monoid.guard (not $ String.null preIcon) $ R.i { className: preIcon <> " mr-3" }
      , R.text $ unemptify text
      , Monoid.guard (not $ String.null icon) $ R.i { className: icon }
      , content
      , Monoid.guard (not $ String.null postIcon) $ R.i { className: postIcon <> " ml-3" }
      ]

    colorClass =
      let
        x = case color of
          Primary -> primary
          Secondary -> secondary
          Success -> success
          Warning -> warning
          Danger -> danger
          Custom x' -> primary
      in
        case fill, bare of
          false, false ->
            String.joinWith " "
              [ x.text
              , x.border
              , "bg-white"
              , x.hover.bg
              ]
          true, false ->
            String.joinWith " "
              $ [ "text-white", x.border, "bg-opacity-10", "hover:text-white", "hover:bg-opacity-100" ]
              <> bool [ x.bg, x.text ] [ x.bg, "text-white", "bg-opacity-100" ] active
          _, true ->
            String.joinWith " "
              [ x.text, "border-transparent" ]

    widthClass = case fullWidth, width of
      false, Nothing -> ""
      false, Just Small -> "w-16"
      false, Just Medium -> "w-32"
      false, Just Large -> "w-64"
      false, Just Full -> "w-full"
      true, _ -> "w-full"

    heightClass = case fullHeight, height of
      false, Nothing -> ""
      false, Just Small -> "h-16"
      false, Just Medium -> "h-32"
      false, Just Large -> "h-64"
      false, Just Full -> "h-full"
      true, _ -> "h_full"

    buttonClass =
      "relative transition duration-200"
        <> " border rounded overflow-hidden overflow-ellipsis"
        <> " appearance-none outline-none focus:ring"
        <> bool " px-3 py-2" " px-2 py-1" dense
        <> bool "" " font-bold" bold
        <> bool "" " text-sm" small
        <> bool "" " bg-opacity-75" translucent
        <> bool "" " text-left" textLeft
        <> bool "" " text-right" textRight
        <> (" " <> colorClass)
        <> mmap (append " ") widthClass
        <> mmap (append " ") heightClass
        <> bool "" " opacity-50 pointer-events-none select-none" disabled

    key = icon <> ":" <> preIcon <> ":" <> postIcon
  bool identity (keyed $ text <> ":" <> key) (key /= "::") case loading of
    Nothing -> case href of
      Nothing ->
        R.button
          { className: buttonClass
          , type: type_
          , disabled
          , onClick: capture_ onClick
          , children: body
          }
      Just href' ->
        R.a
          { className: buttonClass
          , href: href'
          , children: body
          }
    Just loading' ->
      R.button
        { className: buttonClass
        , type: type_
        , disabled: disabled || loading'
        , onClick: capture_ onClick
        , children:
            [ R.div
                { className:
                    "transition duration-200"
                      <> bool "" " opacity-0" loading'
                , children: body
                }
            , R.div
                { className:
                    "absolute inset-0 flex items-center justify-center transition duration-200"
                      <> bool " opacity-0" "" loading'
                , children: pure $ R.i { className: "fas fa-spinner fa-pulse" }
                }
            ]
        }

primary :: _
primary =
  { text: "text-primary-700"
  , bg: "bg-primary-300"
  , border: "border-primary-700"
  , hover:
      { bg: "hover:bg-primary-200"
      }
  }

secondary :: _
secondary =
  { text: "text-secondary"
  , bg: "bg-secondary"
  , border: "border-secondary"
  , hover:
      { bg: "hover:bg-secondary"
      }
  }

success :: _
success =
  { text: "text-success"
  , bg: "bg-success"
  , border:
      "border-success"
  , hover:
      { bg: "hover:bg-success"
      }
  }

warning :: _
warning =
  { text: "text-warning"
  , bg: "bg-warning"
  , border: "border-warning"
  , hover:
      { bg: "hover:bg-warning"
      }
  }

danger :: _
danger =
  { text: "text-danger"
  , bg: "bg-danger"
  , border: "border-danger"
  , hover:
      { bg: "hover:bg-danger"
      }
  }
