module App.View.Page.MitorizanPage where

import AppViewPrelude
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Atom.Value as Value
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Skeleton.Single as Single
import Data.Formatter.Number (Formatter(..), format)
import Data.Int as Int
import Data.Unfoldable (replicate)
import Data.Monoid as Monoid
import Effect.Random as Random
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = {}

type State
  = { digits :: Int
    , lines :: Int
    , count :: Int
    }

type ChildProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

make :: Component Props
make = do
  skeleton <- Single.make
  alpha <- makeAlpha
  component "MitorizanPage" \_ -> React.do
    state /\ setState <- useState { digits: 4, lines: 10, count: 0 }
    pure
      $ skeleton
          { layout: Single.Wide
          , header: renderHeader { state, setState }
          , alpha: alpha { state, setState }
          }

fmt :: Formatter
fmt = Formatter { comma: true, before: 0, after: 0, abbreviations: false, sign: false }

makeAlpha :: Component ChildProps
makeAlpha =
  component "Alpha" \{ state, setState } -> React.do
    numbers /\ setNumbers <- useState ([] :: Array Int)
    generating /\ setGenerating <- useState false
    shortcut <- useKeyboardShortcut
    useEffect unit do
      shortcut.register "Enter" $ setGenerating not
      shortcut.register " " $ setGenerating not
      pure $ pure unit
    useEffect generating do
      when generating do
        ns <- sequence $ replicate state.lines $ Random.randomInt (Int.pow 10 (state.digits - 1)) (Int.pow 10 state.digits - 1)
        setNumbers $ const ns
        setGenerating not
        setState $ _ { count = state.count + 1 }
      pure $ pure unit
    let
      renderNumber n =
        Value.render
          { text: format fmt $ Int.toNumber n
          , large: true
          , justify: Value.JustifyRight
          }
    pure
      $ Container.render
          { flex: Container.Col
          , position: Container.Fill
          , justify: Container.JustifyEnd
          , padding: true
          , fragment:
              [ Monoid.guard (0 < length numbers)
                  $ Scroller.render
                      { grow: true
                      , content:
                          R.div
                            { className: "w-80 mx-auto border-2 border-primary-700 rounded"
                            , children:
                                pure
                                  $ Container.render
                                      { flex: Container.ColNoGap
                                      , padding: true
                                      , fullHeight: true
                                      , fragment:
                                          [ fragment $ renderNumber <$> numbers
                                          , R.hr { className: "border border-divider-500" }
                                          , renderNumber $ foldl (+) 0 numbers
                                          ]
                                      }
                            }
                      }
              , R.div
                  { className: "w-full"
                  , children:
                      pure
                        $ Button.render
                            { color: Button.Primary
                            , width: Button.Full
                            , icon: "fa fa-bolt"
                            , disabled: generating
                            , onClick: setGenerating not
                            }
                  }
              ]
          }

type HeaderProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

renderHeader :: HeaderProps -> JSX
renderHeader { state, setState } =
  Container.render
    { flex: Container.Row
    , align: Container.AlignBaseline
    , padding: true
    , fragment:
        [ R.label
            { className: "text-secondary-700 font-bold"
            , children: pure $ R.text "Digits"
            }
        , R.input
            { className: "p-2 text-right border border-secondary-500 rounded outline-none focus:ring"
            , type: "number"
            , value: show state.digits
            , onChange:
                capture targetValue \x -> do
                  for_ (x >>= Int.fromString) \x' -> do
                    setState $ _ { digits = x' }
            }
        , R.label
            { className: "text-secondary-700 font-bold"
            , children: pure $ R.text "Lines"
            }
        , R.input
            { className: "p-2 text-right border border-secondary-500 rounded outline-none focus:ring"
            , type: "number"
            , value: show state.lines
            , onChange:
                capture targetValue \x -> do
                  for_ (x >>= Int.fromString) \x' -> do
                    setState $ _ { lines = x' }
            }
        , R.div { className: "flex-grow" }
        , Value.render { text: show state.count }
        ]
    }
