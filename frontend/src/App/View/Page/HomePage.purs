module App.View.Page.HomePage where

import AppViewPrelude
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.View.Agent.SpecsAgent (useSpecsAgent)
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Organism.HeaderMenu as HeaderMenu
import App.View.Skeleton.Single as Single
import Data.String as String
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
    useEffect unit do
      specs.load
      pure $ pure unit
    let
      renderSpec spec = do
        let
          { key, name } = unwrap spec

          route = case String.stripPrefix (wrap "shuzan-") key of
            Nothing -> Route.Home
            Just key' -> Route.Shuzan key'
        R.div
          { className: "p-2 w-1/4"
          , children:
              [ Button.render
                  { text: name
                  , fullWidth: true
                  , onClick: navigate route
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
