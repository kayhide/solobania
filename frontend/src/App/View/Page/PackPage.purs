module App.View.Page.PackPage where

import AppViewPrelude
import App.Data (toId)
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.Data.Pack (Pack, PackId)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Atom.Value as Value
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Skeleton.Single as Single
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Sl as Sl
import Data.Array as Array
import Data.Formatter.Number (Formatter(..), format)
import Data.Int as Int
import Data.Lens (_Just, to)
import Data.Lens.Index (ix)
import Data.Monoid as Monoid
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = { packId :: PackId }

type State
  = { pack :: Maybe Pack
    , sheetIndex :: Int
    , problemIndex :: Int
    , font :: String
    }

type ChildProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

emptifyState :: State -> State
emptifyState = _ { pack = Nothing, sheetIndex = 0, problemIndex = 0 }

make :: Component Props
make = do
  skeleton <- Single.make
  header <- HeaderMenu.make
  alpha <- makeAlpha
  component "PackPage" \{ packId } -> React.do
    packs <- usePacksAgent
    state /\ setState <-
      useState
        { pack: Nothing
        , sheetIndex: 0
        , problemIndex: 0
        , font: "font-caveat"
        }
    useEffect packId do
      packs.loadOne packId
      pure $ pure unit
    useEffect packs.item do
      setState $ _ { pack = packs.item }
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
      currentSheet = state.pack ^? _Just <<< to (unwrap >>> _.sheets) <<< ix state.sheetIndex

      currentProblem = currentSheet ^? _Just <<< to (unwrap >>> _.problems) <<< ix state.problemIndex

      numbers /\ count =
        fromMaybe ([] /\ 0) do
          sheet <- currentSheet
          problem <- currentProblem
          pure $ (problem # unwrap >>> _.body >>> unwrap >>> _.question) /\ length (unwrap sheet).problems

      rewind = case 0 < state.problemIndex of
        false -> case 0 < state.sheetIndex of
          false -> pure unit
          true -> do
            let
              prevSheet = state.pack ^? _Just <<< to (unwrap >>> _.sheets) <<< ix (state.sheetIndex - 1)

              problemIndex =
                fromMaybe 0
                  $ prevSheet
                  ^? _Just
                  <<< to (unwrap >>> _.problems >>> length >>> (_ - 1))
            setState $ _ { sheetIndex = state.sheetIndex - 1, problemIndex = problemIndex }
        true -> setState $ _ { problemIndex = state.problemIndex - 1 }

      proceed =
        case state.problemIndex < count - 1 of
          false -> setState $ _ { sheetIndex = state.sheetIndex + 1, problemIndex = 0 }
          true -> setState $ _ { problemIndex = state.problemIndex + 1 }
    shortcut <- useKeyboardShortcut
    useEffect (currentProblem /\ state.problemIndex) do
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
                      fragment
                        [ Sl.card
                            { className: "w-full"
                            , children:
                                [ R.div
                                    { slot: "header"
                                    , className: "text-center"
                                    , children: [ R.text $ show (state.problemIndex + 1) <> " / " <> show count ]
                                    }
                                , R.div
                                    { className: "w-full " <> state.font
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
                        ]
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
renderHeader { state, setState } = do
  fromMaybe mempty do
    pack <- state.pack
    sheet <- (unwrap pack).sheets ^? ix state.sheetIndex
    pure
      $ Container.render
          { flex: Container.Row
          , align: Container.AlignBaseline
          , justify: Container.JustifyBetween
          , padding: true
          , fragment:
              [ R.div
                  { className: "text-secondary-700 text-xl"
                  , children: pure $ R.text $ (unwrap pack).name <> " " <> (unwrap sheet).name
                  }
              , Sl.select
                  { value: state.font
                  , className: "w-48"
                  , onSlInput:
                      capture targetValue \x -> do
                        for_ x \x' ->
                          setState $ _ { font = x' }
                  , children:
                      fonts
                        <#> \{ label, value } ->
                            Sl.option { label, value, children: [ R.text label ] }
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
