module App.View.Atom.Scroller where

import AppViewPrelude
import App.View.Atom.Container as Container
import Prim.Row as Row
import React.Basic.DOM as R
import Record as Record

data Color
  = Primary
  | Secondary
  | White
  | NoColor

type PropsRow
  = ( content :: JSX
    | PropsRowOptional
    )

type PropsRowOptional
  = ( color :: Color
    , padding :: Boolean
    , fullHeight :: Boolean
    , someWidth :: Boolean
    , grow :: Boolean
    )

type Props
  = { | PropsRow }

def :: { | PropsRowOptional }
def =
  { color: NoColor
  , padding: false
  , fullHeight: false
  , someWidth: false
  , grow: false
  }

render ::
  forall props props'.
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render props = do
  let
    { content, color, padding, fullHeight, someWidth, grow } = Record.merge props def :: Props

    colorClass = case color of
      Primary -> "bg-background-primary"
      Secondary -> "bg-background-secondary"
      White -> "bg-white"
      NoColor -> ""
  R.div
    { className:
        "relative"
          <> bool "" " h-full" fullHeight
          <> bool "" " w-60" someWidth
          <> bool "" " flex-grow" grow
          <> (mmap (append " ") colorClass)
    , children:
        pure
          $ R.div
              { className: "absolute inset-0 overflow-y-auto"
              , children:
                  pure
                    $ Container.render
                        { content, padding }
              }
    }
