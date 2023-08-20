module App.View.Page.HomePage where

import AppViewPrelude
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.View.Organism.HeaderMenu as HeaderMenu
import App.Soloban as Soloban
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Value as Value
import App.View.Skeleton.Single as Single
import Data.Map as Map
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
    let
      renderSpec (key /\ spec) = do
        let
          { label, subjects } = unwrap spec

          route = case String.stripPrefix (wrap "shuzan-") key of
            Nothing -> Route.Home
            Just key' -> Route.Shuzan key'
        R.div
          { className: "p-2 w-1/4"
          , children:
              [ Button.render
                  { text: label
                  , fullWidth: true
                  , onClick: navigate route
                  , content:
                      Container.render
                        { flex: Container.ColNoGap
                        , fragment:
                            subjects
                              <#> \(name /\ _) ->
                                  Value.render
                                    { text: name
                                    , dense: true
                                    }
                        }
                  }
              ]
          }
    pure
      $ Container.render
          { flex: Container.RowWrapping
          , position: Container.Fill
          , fragment:
              [ fragment
                  $ renderSpec
                  <$> Map.toUnfoldable Soloban.store
              ]
          }
