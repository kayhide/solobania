module App.View.Page.HomePage where

import AppViewPrelude
import App.Data (toId)
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Agent.SpecsAgent (useSpecsAgent)
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Organism.HeaderMenu as HeaderMenu
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

make :: Component Props
make = do
  skeleton <- Single.make
  header <- HeaderMenu.make
  alpha <- makeAlpha
  component "HomePage" \_ -> React.do
    state /\ setState <- useState {}
    pure
      $ skeleton
          { layout: Single.Wide
          , header: header {}
          , alpha: alpha { state, setState }
          }

makeAlpha :: Component ChildProps
makeAlpha =
  component "Alpha" \_ -> React.do
    specs <- useSpecsAgent
    packs <- usePacksAgent
    useEffect unit do
      specs.load
      pure $ pure unit
    useEffect packs.createdItem do
      for_ packs.createdItem \pack' -> do
        navigate $ Route.Pack (toId pack')
      pure $ pure unit
    let
      renderSpec spec = do
        let
          { id, name } = unwrap spec
        R.div
          { className: "p-2 w-1/4"
          , children:
              [ Button.render
                  { text: name
                  , loading: packs.isLoading
                  , fullWidth: true
                  , onClick:
                      do
                        packs.setSpecId id
                        packs.create $ wrap unit
                  }
              ]
          }
    pure
      $ Container.render
          { flex: Container.RowWrapping
          , position: Container.Fill
          , fragment:
              renderSpec
                <$> specs.items
          }
