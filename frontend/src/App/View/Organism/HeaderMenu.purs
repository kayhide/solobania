module App.View.Organism.HeaderMenu where

import AppViewPrelude
import App.Context (context)
import App.Data.Route as Route
import App.I18n.Ja as Ja
import App.View.Atom.Container as Container
import App.View.Atom.MenuItem as MenuItem
import App.View.Molecule.Dropdown as Dropdown
import App.View.Molecule.FontPicker as FontPicker
import Data.Monoid as Monoid
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = {}

render :: Props -> JSX
render =
  renderComponent do
    component "HeaderMenu" \_ -> React.do
      { route, currentProfile } <- useContext context
      pure
        $ R.nav
            { className: "px-6 flex items-center bg-white border-b border-divider"
            , children:
                [ MenuItem.render
                    { dst: Route.Home
                    , text: "Solobania"
                    , bold: true
                    , luminous: true
                    }
                , currentProfile
                    # maybe mempty \{ user } ->
                        fragment
                          [ Container.render
                              { flex: Container.Row
                              , align: Container.AlignCenter
                              , fullHeight: true
                              , fragment:
                                  [ MenuItem.render
                                      { dst: Route.Mitorizan
                                      , active: route == Route.Mitorizan
                                      , bold: true
                                      , text: "Mitorizan"
                                      }
                                  ]
                              }
                          , R.div
                              { className: "flex-grow"
                              }
                          , FontPicker.render {}
                          , Container.render
                              { flex: Container.Row
                              , align: Container.AlignCenter
                              , fullHeight: true
                              , fragment:
                                  [ Monoid.guard (unwrap user).admin
                                      MenuItem.render
                                      { dst: Route.Home
                                      , active: false
                                      , small: true
                                      , text: "Admin"
                                      }
                                  , Dropdown.render
                                      { className: "self-stretch flex"
                                      , align: Dropdown.AlignRight
                                      , trigger:
                                          \handle ->
                                            MenuItem.render
                                              { onClick: handle
                                              , bold: false
                                              , small: true
                                              , icon: "fas fa-cog"
                                              , color: MenuItem.Secondary
                                              }
                                      , content:
                                          R.div
                                            { className: "w-48 bg-white shadow-md rounded-md overflow-hidden"
                                            , children:
                                                [ MenuItem.render
                                                    { text: (unwrap user).username
                                                    , tall: true
                                                    , color: MenuItem.Secondary
                                                    , preIcon: "fas fa-user"
                                                    }
                                                , MenuItem.render
                                                    { dst: Route.Logout
                                                    , tall: true
                                                    , color: MenuItem.Secondary
                                                    , text: Ja.logout
                                                    }
                                                ]
                                            }
                                      }
                                  ]
                              }
                          ]
                ]
            }
