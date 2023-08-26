module App.View.Page.MitorizanPage where

import AppViewPrelude
import App.Context (context)
import App.View.Organism.HeaderMenu as HeaderMenu
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
import App.View.Sl as Sl

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
  header <- HeaderMenu.make
  alpha <- makeAlpha
  component "MitorizanPage" \_ -> React.do
    state /\ setState <- useState { digits: 4, lines: 10, count: 0 }
    pure
      $ skeleton
          { layout: Single.Wide
          , header:
              fragment
                [ header {}
                , renderHeader { state, setState }
                ]
          , alpha: alpha { state, setState }
          }

fmt :: Formatter
fmt = Formatter { comma: true, before: 0, after: 0, abbreviations: false, sign: false }

makeAlpha :: Component ChildProps
makeAlpha =
  component "Alpha" \{ state, setState } -> React.do
    { font } <- useContext context
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
          , dense: true
          , huge: true
          , justify: Value.JustifyRight
          }
    pure
      $ fragment
          [ Container.render
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
                                { className: "w-80 mx-auto border-2 border-primary-700 rounded " <> font.current
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
                  , Button.render
                      { variant: Button.Primary
                      , fill: false
                      , icon: "fa fa-bolt"
                      , onClick: setGenerating not
                      }
                  ]
              }
          , R.div
              { className: "absolute top-0 right-0 mx-16 text-4xl " <> font.current
              , children: [ R.text $ show state.count ]
              }
          ]

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
    , fullWidth: true
    , fragment:
        [ R.label
            { className: "text-secondary-700 font-bold"
            , children: pure $ R.text "Digits"
            }
        , Container.render
            { flex: Container.RowDense
            , fragment:
                [ Sl.input
                    { className: "w-32 text-right"
                    , type: "number"
                    , value: show $ state.digits
                    , onSlInput:
                        capture targetValue \x -> do
                          for_ (x >>= Int.fromString) \x' -> do
                            setState $ _ { digits = x', count = 0 }
                    }
                , Sl.button_group
                    { children:
                        [ Sl.button
                            { onClick: capture_ $ setState $ _ { digits = state.digits + 1, count = 0 }
                            , children: R.i { className: "fa fa-angle-up" }
                            }
                        , Sl.button
                            { onClick: capture_ $ setState $ _ { digits = state.digits - 1, count = 0 }
                            , children: R.i { className: "fa fa-angle-down" }
                            }
                        ]
                    }
                ]
            }
        , R.label
            { className: "text-secondary-700 font-bold"
            , children: pure $ R.text "Lines"
            }
        , Container.render
            { flex: Container.RowDense
            , fragment:
                [ Sl.input
                    { className: "w-32 text-right"
                    , type: "number"
                    , value: show $ state.lines
                    , onSlInput:
                        capture targetValue \x -> do
                          for_ (x >>= Int.fromString) \x' -> do
                            setState $ _ { lines = x', count = 0 }
                    }
                , Sl.button_group
                    { children:
                        [ Sl.button
                            { onClick: capture_ $ setState $ _ { lines = state.lines + 1, count = 0 }
                            , children: R.i { className: "fa fa-angle-up" }
                            }
                        , Sl.button
                            { onClick: capture_ $ setState $ _ { lines = state.lines - 1, count = 0 }
                            , children: R.i { className: "fa fa-angle-down" }
                            }
                        ]
                    }
                ]
            }
        ]
    }
