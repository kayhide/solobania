module App.View.Page.PackPage where

import AppViewPrelude
import App.Data.Pack (Pack, PackId)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Organism.MitorizanPanel as MitorizanPanel
import App.View.Skeleton.Single as Single
import Data.Lens (_Just, to)
import Data.Lens.Index (ix)
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = { packId :: PackId }

type State
  = { pack :: Maybe Pack
    , sheetIndex :: Int
    , problemIndex :: Int
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

makeAlpha :: Component ChildProps
makeAlpha =
  component "Alpha" \{ state, setState } -> React.do
    let
      sheets = state.pack ^. _Just <<< to (unwrap >>> _.sheets)

      currentSheet = sheets ^? ix state.sheetIndex

      problems = currentSheet ^. _Just <<< to (unwrap >>> _.problems)

      currentProblem = problems ^? ix state.problemIndex

      count = length problems

      rewind = case 0 < state.problemIndex, 0 < state.sheetIndex of
        false, false -> pure unit
        false, true -> do
          let
            problemIndex =
              fromMaybe 0
                $ sheets
                ^? ix (state.sheetIndex - 1)
                <<< to (unwrap >>> _.problems >>> length >>> (_ - 1))
          setState $ _ { sheetIndex = state.sheetIndex - 1, problemIndex = problemIndex }
        true, _ -> setState $ _ { problemIndex = state.problemIndex - 1 }

      proceed = case state.problemIndex < count - 1, state.sheetIndex < length sheets - 1 of
        false, false -> pure unit
        false, true -> setState $ _ { sheetIndex = state.sheetIndex + 1, problemIndex = 0 }
        true, _ -> setState $ _ { problemIndex = state.problemIndex + 1 }
    shortcut <- useKeyboardShortcut
    useEffect (currentProblem /\ state.problemIndex) do
      shortcut.register "Backspace" rewind
      shortcut.register "Enter" proceed
      shortcut.register " " proceed
      pure $ pure unit
    pure
      $ Container.render
          { flex: Container.Row
          , position: Container.Fill
          , justify: Container.JustifyBetween
          , padding: true
          , fragment:
              currentProblem
                # maybe [] \problem ->
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
                            MitorizanPanel.render
                              { problem
                              , title: show (state.problemIndex + 1) <> " / " <> show count
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
              ]
          }
