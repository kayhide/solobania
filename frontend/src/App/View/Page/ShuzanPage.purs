module App.View.Page.ShuzanPage where

import AppViewPrelude
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Atom.Value as Value
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Skeleton.Single as Single
import Data.Formatter.Number (Formatter(..), format)
import Data.Int as Int
import Data.Array as Array
import Data.Monoid as Monoid
import React.Basic.DOM as R
import React.Basic.Hooks as React
import App.Soloban (Problem(..), Spec, Subject, generate)
import App.Soloban as Soloban

type Props
  = { key :: String }

type State
  = { spec :: Maybe Spec
    , problems :: Array Problem
    , currentSubject :: Maybe (String /\ Subject)
    , currentProblem :: Maybe Problem
    , index :: Int
    , font :: String
    }

type ChildProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

make :: Component Props
make = do
  skeleton <- Single.make
  alpha <- makeAlpha
  component "ShuzanPage" \{ key } -> React.do
    state /\ setState <- useState { spec: Nothing, problems: [], currentSubject: Nothing, currentProblem: Nothing, index: 0, font: "font-caveat" }
    let
      emptifyState = _ { spec = Nothing, problems = [], currentSubject = Nothing, currentProblem = Nothing, index = 0 }
    useEffect key do
      case key of
        "15" -> setState $ emptifyState >>> _ { spec = Just Soloban.shuzan_15 }
        _ -> pure unit
      pure $ pure unit
    useEffect state.spec do
      for_ state.spec \spec' -> do
        let
          { subjects } = unwrap spec'
        problems <- sequence $ generate <<< snd <$> subjects
        setState $ _ { problems = problems, currentSubject = Array.head subjects, currentProblem = Array.head problems }
      pure $ pure unit
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
    let
      proceed = setState $ _ { index = state.index + 1 }
    shortcut <- useKeyboardShortcut
    useEffect state.index do
      shortcut.register "Enter" proceed
      shortcut.register " " proceed
      pure $ pure unit
    let
      numbers =
        fromMaybe [] do
          problem <- state.currentProblem
          case problem of
            MitoriProblem xs -> (_.numbers) <$> Array.index xs state.index
            _ -> Nothing

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
                          R.div
                            { className: "w-80 mx-auto border-2 border-primary-700 rounded " <> state.font
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
renderHeader { state, setState } = case { spec: _, subject: _, problem: _ } <$> state.spec <*> state.currentSubject <*> state.currentProblem of
  Nothing -> mempty
  Just { spec, subject, problem } ->
    Container.render
      { flex: Container.Row
      , align: Container.AlignBaseline
      , padding: true
      , fragment:
          [ R.div
              { className: "text-secondary-700 text-xl"
              , children: pure $ R.text $ (unwrap spec).label <> " " <> fst subject
              }
          , R.div
              { className: "text-secondary-700"
              , children: pure $ R.text $ show (state.index + 1) <> " / " <> show (Soloban.problemCount problem)
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
