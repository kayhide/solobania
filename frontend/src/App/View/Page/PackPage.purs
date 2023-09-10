module App.View.Page.PackPage where

import AppViewPrelude
import App.Data (toId, updating)
import App.Data.Act (Mark(..))
import App.Data.Pack (Pack, PackId)
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.View.Agent.ActsAgent (useActsAgent)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Organism.ProblemPanel as ProblemPanel
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
    , starting :: Boolean
    , finishing :: Boolean
    }

type ChildProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

emptifyState :: State -> State
emptifyState = _ { pack = Nothing, sheetIndex = 0, problemIndex = 0 }

render :: Props -> JSX
render =
  renderComponent do
    component "PackPage" \{ packId } -> React.do
      packs <- usePacksAgent
      state /\ setState <-
        useState
          { pack: Nothing
          , sheetIndex: 0
          , problemIndex: 0
          , starting: false
          , finishing: false
          }
      useEffect packId do
        packs.loadOne packId
        pure $ pure unit
      useEffect packs.item do
        setState $ _ { pack = packs.item }
        pure $ pure unit
      useEffect packId do
        setState $ _ { starting = true, finishing = false }
        pure $ pure unit
      pure
        $ Single.render
            { layout: Single.Wide
            , header:
                fragment
                  [ HeaderMenu.render {}
                  , renderHeader { state, setState }
                  ]
            , alpha: alpha { state, setState }
            }

alpha :: ChildProps -> JSX
alpha =
  renderComponent do
    component "Alpha" \{ state, setState } -> React.do
      acts <- useActsAgent
      let
        sheets = state.pack ^. _Just <<< to (unwrap >>> _.sheets)

        currentSheet = sheets ^? ix state.sheetIndex

        problems = currentSheet ^. _Just <<< to (unwrap >>> _.problems)

        currentProblem = problems ^? ix state.problemIndex <* guard (not state.starting && not state.finishing)

        count = length problems
      useEffect currentProblem do
        for_ currentProblem \problem -> do
          acts.setProblemId $ toId problem
          acts.create $ wrap unit
        pure $ pure unit
      let
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

        proceed = do
          for_ acts.createdItem \act -> do
            acts.update $ updating act { mark: Just Confident }
          case state.problemIndex < count - 1, state.sheetIndex < length sheets - 1 of
            false, false -> setState $ _ { finishing = true }
            false, true -> setState $ _ { sheetIndex = state.sheetIndex + 1, problemIndex = 0 }
            true, _ -> setState $ _ { problemIndex = state.problemIndex + 1 }
      shortcut <- useKeyboardShortcut
      useEffect (toId <$> currentProblem) do
        case currentProblem of
          Nothing -> shortcut.reset
          Just _ -> do
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
            , content:
                case state.starting, state.finishing of
                  true, _ ->
                    Button.render
                      { text: "Start"
                      , size: Button.Large
                      , fullWidth: true
                      , loading: acts.isSubmitting
                      , onClick: setState $ _ { starting = false }
                      }
                  false, true ->
                    Button.render
                      { text: "Finish"
                      , size: Button.Large
                      , fullWidth: true
                      , loading: acts.isSubmitting
                      , onClick: navigate Route.Home
                      }
                  _, _ ->
                    fragment
                      $ currentProblem
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
                          , Container.render
                              { someWidth: true
                              , content:
                                  ProblemPanel.render
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
                  , children:
                      pure
                        $ R.text
                        $ (unwrap pack).name
                        <> (bool "" (" " <> (unwrap sheet).name)) (not state.starting && not state.finishing)
                  }
              ]
          }
