module App.View.Page.ShuzanPage where

import AppViewPrelude
import App.Context (context)
import App.Soloban (Problem(..), Spec, generate, problemCount)
import App.Soloban as Soloban
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Atom.Value as Value
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Skeleton.Single as Single
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Sl as Sl
import Data.Formatter.Number (Formatter(..), format)
import Data.Int as Int
import Data.Lens (_Just, to)
import Data.Lens.Index (ix)
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = { key :: String }

type State
  = { spec :: Maybe Spec
    , problems :: Array Problem
    , subjectIndex :: Int
    , index :: Int
    }

type ChildProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

emptifyState :: State -> State
emptifyState = _ { spec = Nothing, problems = [], subjectIndex = 0, index = 0 }

make :: Component Props
make = do
  skeleton <- Single.make
  header <- HeaderMenu.make
  alpha <- makeAlpha
  component "ShuzanPage" \{ key } -> React.do
    state /\ setState <-
      useState
        { spec: Nothing
        , problems: []
        , subjectIndex: 0
        , index: 0
        }
    useEffect key do
      setState $ emptifyState >>> _ { spec = Soloban.store ^? ix ("shuzan-" <> key) }
      pure $ pure unit
    useEffect state.spec do
      for_ state.spec \spec' -> do
        let
          { subjects } = unwrap spec'
        problems <- sequence $ generate <<< snd <$> subjects
        setState $ _ { problems = problems }
      pure $ pure unit
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
    let
      currentProblem = state.problems ^? ix state.subjectIndex

      numbers /\ count =
        fromMaybe ([] /\ 0) do
          problem <- currentProblem
          case problem of
            MitoriProblem xs -> xs ^? ix state.index <<< to _.numbers <<< to (_ /\ length xs)
            _ -> Nothing

      rewind = do
        case 0 < state.index of
          false -> case 0 < state.subjectIndex of
            false -> pure unit
            true -> do
              let
                index =
                  fromMaybe 0
                    $ state.problems
                    ^? ix (state.subjectIndex - 1)
                    <<< to problemCount
                    <<< to (_ - 1)
              setState $ _ { subjectIndex = state.subjectIndex - 1, index = index }
          true -> setState $ _ { index = state.index - 1 }

      proceed = do
        case state.index < count - 1 of
          false -> setState $ _ { subjectIndex = state.subjectIndex + 1, index = 0 }
          true -> setState $ _ { index = state.index + 1 }
    shortcut <- useKeyboardShortcut
    useEffect (currentProblem /\ state.index) do
      shortcut.register "Backspace" rewind
      shortcut.register "Enter" proceed
      shortcut.register " " proceed
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
      $ Container.render
          { flex: Container.Row
          , position: Container.Fill
          , justify: Container.JustifyBetween
          , padding: true
          , fragment:
              [ R.div
                  { className: "flex-1"
                  , children:
                      pure
                        $ Button.render
                            { variant: Button.Primary
                            , icon: "fa fa-angle-left"
                            , bare: true
                            , textLeft: true
                            , fullWidth: true
                            , fullHeight: true
                            , onClick: rewind
                            }
                  }
              , Scroller.render
                  { shrink: false
                  , someWidth: true
                  , content:
                      Sl.card
                        { className: "w-full"
                        , children:
                            [ R.div
                                { slot: "header"
                                , className: "text-center"
                                , children: [ R.text $ show (state.index + 1) <> " / " <> show count ]
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
                  }
              , R.div
                  { className: "flex-1"
                  , children:
                      pure
                        $ Button.render
                            { variant: Button.Primary
                            , icon: "fa fa-angle-right"
                            , bare: true
                            , textRight: true
                            , fullWidth: true
                            , fullHeight: true
                            , onClick: proceed
                            }
                  }
              ]
          }

type HeaderProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

renderHeader :: HeaderProps -> JSX
renderHeader { state } = do
  let
    currentSubject = state.spec ^? _Just <<< to unwrap <<< to _.subjects <<< ix state.subjectIndex
  case { spec: _, subject: _ } <$> state.spec <*> currentSubject of
    Nothing -> mempty
    Just { spec, subject } ->
      Container.render
        { flex: Container.Row
        , align: Container.AlignBaseline
        , justify: Container.JustifyBetween
        , padding: true
        , fragment:
            [ R.div
                { className: "text-secondary-700 text-xl"
                , children: pure $ R.text $ (unwrap spec).label <> " " <> fst subject
                }
            ]
        }
