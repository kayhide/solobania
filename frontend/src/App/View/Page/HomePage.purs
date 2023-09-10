module App.View.Page.HomePage where

import AppViewPrelude
import App.Data (toId)
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.Data.Spec (Spec)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Agent.SpecsAgent (useSpecsAgent)
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Organism.HistoryPanel as HistoryPanel
import App.View.Skeleton.Single as Single
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = {}

type State
  = {}

type ChildProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

render :: Props -> JSX
render =
  renderComponent do
    component "HomePage" \_ -> React.do
      state /\ setState <- useState {}
      pure
        $ Single.render
            { layout: Single.Wide
            , header: HeaderMenu.render {}
            , alpha: alpha { state, setState }
            }

alpha :: ChildProps -> JSX
alpha =
  renderComponent do
    component "Alpha" \_ -> React.do
      pure
        $ Scroller.render
            { grow: true
            , fullHeight: true
            , content:
                fragment
                  [ renderSpecsPanel {}
                  , HistoryPanel.render {}
                  ]
            }

renderSpecsPanel :: {} -> JSX
renderSpecsPanel =
  unsafePerformEffect
    $ component "SpecsPanel" \_ -> React.do
        specs <- useSpecsAgent
        useEffect unit do
          specs.load
          pure $ pure unit
        pure
          $ Container.render
              { flex: Container.RowWrapping
              , fullWidth: true
              , loading: specs.isLoading
              , fragment:
                  renderSpec
                    <$> specs.items
              }

renderSpec :: Spec -> JSX
renderSpec =
  unsafePerformEffect
    $ component "Spec" \spec -> React.do
        packs <- usePacksAgent
        useEffect packs.createdItem do
          for_ packs.createdItem \pack' -> do
            navigate $ Route.Pack (toId pack')
          pure $ pure unit
        let
          { id, name } = unwrap spec
        pure
          $ R.div
              { className: "p-2 w-1/4"
              , children:
                  [ Button.render
                      { text: name
                      , loading: packs.isSubmitting
                      , fullWidth: true
                      , onClick:
                          do
                            packs.setSpecId id
                            packs.create $ wrap unit
                      }
                  ]
              }
