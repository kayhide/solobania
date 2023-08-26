module App.View.Organism.MitorizanPanel where

import AppViewPrelude
import App.Context (context)
import App.Data.Problem (Problem)
import App.View.Atom.Container as Container
import App.View.Atom.Value as Value
import App.View.Sl as Sl
import Data.Formatter.Number (Formatter(..), format)
import Data.Int as Int
import Prim.Row as Row
import React.Basic.DOM as R
import React.Basic.Hooks as React
import Record as Record

type PropsRow
  = ( problem :: Problem
    | PropsRowOptional
    )

type PropsRowOptional
  = ( title :: String
    )

type Props
  = { | PropsRow }

def :: { | PropsRowOptional }
def =
  { title: ""
  }

fmt :: Formatter
fmt = Formatter { comma: true, before: 0, after: 0, abbreviations: false, sign: false }

renderNumber :: Int -> JSX
renderNumber n =
  Value.render
    { text: format fmt $ Int.toNumber n
    , dense: true
    , huge: true
    , justify: Value.JustifyRight
    }

make ::
  forall props props'.
  Row.Lacks "key" props =>
  Row.Lacks "children" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  Component { | props }
make = do
  component "MitrozanPanel" \props -> React.do
    { font } <- useContext context
    let
      { problem
      , title
      } = Record.merge props def :: Props
    let
      numbers = problem # unwrap >>> _.body >>> unwrap >>> _.question
    pure
      $ Sl.card
          { className: "w-full"
          , children:
              [ R.div
                  { slot: "header"
                  , className: "text-center"
                  , children: [ R.text title ]
                  }
              , R.div
                  { className: "w-full " <> font.current
                  , children:
                      pure
                        $ Container.render
                            { flex: Container.ColNoGap
                            , fullHeight: true
                            , fragment:
                                [ fragment $ renderNumber <$> numbers
                                , R.hr { className: "border border-divider-500" }
                                , renderNumber $ foldl (+) 0 numbers
                                ]
                            }
                  }
              ]
          }

render ::
  forall props props'.
  Row.Lacks "key" props =>
  Row.Lacks "children" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render = unsafePerformEffect make
