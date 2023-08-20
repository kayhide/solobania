module App.View.Page.HomePage where

import AppViewPrelude
import App.Data.Route (navigate)
import App.Data.Route as Route
import App.Soloban (Problem(..), Spec, Subject, generate)
import App.Soloban as Soloban
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Atom.Scroller as Scroller
import App.View.Atom.Value as Value
import App.View.Helper.KeyboardShortcut (useKeyboardShortcut)
import App.View.Skeleton.Single as Single
import Data.Array as Array
import Data.Formatter.Number (Formatter(..), format)
import Data.Int as Int
import Data.Lens.Index (ix)
import Data.Map as Map
import Data.Monoid as Monoid
import Data.String as String
import Data.Unfoldable (replicate)
import Effect.Random as Random
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
  alpha <- makeAlpha
  component "HomePage" \_ -> React.do
    state /\ setState <- useState {}
    pure
      $ skeleton
          { layout: Single.Wide
          , header: renderHeader { state, setState }
          , alpha: alpha { state, setState }
          }

makeAlpha :: Component ChildProps
makeAlpha =
  component "Alpha" \{ state, setState } -> React.do
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

type HeaderProps
  = { state :: State
    , setState :: (State -> State) -> Effect Unit
    }

renderHeader :: HeaderProps -> JSX
renderHeader { state, setState } =
  Container.render
    { flex: Container.Row
    , align: Container.AlignBaseline
    , padding: true
    }
