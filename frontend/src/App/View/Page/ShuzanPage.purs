module App.View.Page.ShuzanPage where

import AppViewPrelude
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.Soloban (Problem(..), Spec, generate)
import App.Soloban as Soloban
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Atom.Value as Value
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Skeleton.Single as Single
import App.View.Organism.HeaderMenu as HeaderMenu
import Data.Array as Array
import Data.Formatter.Number (Formatter(..), format)
import Data.Int as Int
import Data.Lens (_Just, to)
import Data.Lens.Index (ix)
import Data.Monoid as Monoid
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = { key :: String }

type State
  = { spec :: Maybe Spec
    , problems :: Array Problem
    , subjectIndex :: Int
    , index :: Int
    , font :: String
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
        , font: "font-caveat"
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
    let
      currentProblem = state.problems ^? ix state.subjectIndex

      numbers /\ count =
        fromMaybe ([] /\ 0) do
          problem <- currentProblem
          case problem of
            MitoriProblem xs -> xs ^? ix state.index <<< to _.numbers <<< to (_ /\ length xs)
            _ -> Nothing

      proceed = do
        case state.index < count - 1 of
          false -> setState $ _ { subjectIndex = state.subjectIndex + 1, index = 0 }
          true -> setState $ _ { index = state.index + 1 }
    shortcut <- useKeyboardShortcut
    useEffect (currentProblem /\ state.index) do
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
          { flex: Container.Col
          , position: Container.Fill
          , justify: Container.JustifyEnd
          , padding: true
          , fragment:
              [ Monoid.guard (0 < length numbers)
                  $ Scroller.render
                      { grow: true
                      , content:
                          fragment
                            [ R.div
                                { className: "w-80 mx-auto p-2 text-center text-primary-900 border-x-2 border-t-2 border-primary-700 bg-primary-200 rounded-t"
                                , children:
                                    pure
                                      $ R.text
                                      $ show (state.index + 1)
                                      <> " / "
                                      <> show count
                                }
                            , R.div
                                { className: "w-80 mx-auto border-x-2 border-b-2 border-primary-700 rounded-b " <> state.font
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
                            ]
                      }
              , R.div
                  { className: "flex-0 w-full pb-8"
                  , children:
                      pure
                        $ Button.render
                            { color: Button.Primary
                            , width: Button.Full
                            , icon: "fa fa-bolt"
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
renderHeader { state, setState } = do
  let
    currentSubject = state.spec ^? _Just <<< to unwrap <<< to _.subjects <<< ix state.subjectIndex
  case { spec: _, subject: _ } <$> state.spec <*> currentSubject of
    Nothing -> mempty
    Just { spec, subject } ->
      Container.render
        { flex: Container.Row
        , align: Container.AlignBaseline
        , padding: true
        , fragment:
            [ R.div
                { className: "text-secondary-700 text-xl"
                , children: pure $ R.text $ (unwrap spec).label <> " " <> fst subject
                }
            , R.div { className: "flex-grow" }
            , Container.render
                { flex: Container.RowDense
                , fragment:
                    [ R.select
                        { className: "p-2 border border-secondary-500 rounded outline-none focus:ring"
                        , value: state.font
                        , onChange:
                            capture targetValue \x -> do
                              for_ x \x' ->
                                setState $ _ { font = x' }
                        , children:
                            fonts
                              <#> \{ label, value } ->
                                  R.option { label, value, children: pure $ R.text label }
                        }
                    ]
                }
            ]
        }

fonts ::
  Array
    { label :: String
    , value :: String
    }
fonts =
  [ { label: "Caveat", value: "font-caveat" }
  , { label: "Damion", value: "font-damion" }
  , { label: "Short Stack", value: "font-short-stack" }
  ]
