module App.View.Organism.HeaderEmpty where

import AppViewPrelude
import App.Data.Route as Route
import App.View.Atom.MenuItem as MenuItem
import React.Basic.DOM as R

type Props
  = {}

make :: Component Props
make = do
  component "HeaderEmpty" \_ ->
    pure
      $ R.nav
          { className: "px-6 flex items-center bg-white border-b border-divider"
          , children:
              [ R.div
                  { className: ""
                  , children:
                      [ MenuItem.render
                          { dst: Route.Home
                          , text: "Solobania"
                          , bold: true
                          , luminous: true
                          }
                      ]
                  }
              ]
          }
