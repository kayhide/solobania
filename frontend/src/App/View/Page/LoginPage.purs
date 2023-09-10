module App.View.Page.LoginPage where

import AppViewPrelude
import App.I18n.Ja as Ja
import App.View.Agent.SessionsAgent (SessionsAgent)
import App.View.Atom.Button as Button
import App.View.Atom.Container as Container
import App.View.Organism.HeaderEmpty as HeaderEmpty
import App.View.Skeleton.Single as Single
import Data.String as String
import React.Basic.DOM as R
import React.Basic.Hooks as React

type Props
  = { sessions :: SessionsAgent
    }

render :: Props -> JSX
render =
  renderComponent do
    component "LoginPage" \{ sessions } -> React.do
      pure
        $ Single.render
            { layout: Single.Narrow
            , header: HeaderEmpty.render {}
            , alpha:
                R.div
                  { className: "w-full mt-24"
                  , children: pure $ renderForm { sessions }
                  }
            }

renderForm :: { sessions :: SessionsAgent } -> JSX
renderForm =
  renderComponent do
    component "LoginForm" \{ sessions } -> React.do
      email /\ setEmail <- useState ""
      password /\ setPassword <- useState ""
      submitting /\ setSubmitting <- useState false
      useAff sessions.isBusy do
        liftEffect $ setSubmitting $ const sessions.isBusy
      pure
        $ R.form
            { className: "bg-white shadow-md rounded"
            , children:
                pure
                  $ Container.render
                      { flex: Container.Col
                      , padding: true
                      , fragment:
                          [ renderInput Ja.email { type_: "email", value: email, update: setEmail <<< const }
                          , renderInput Ja.password { type_: "password", value: password, update: setPassword <<< const }
                          , Container.render
                              { flex: Container.Row
                              , justify: Container.JustifyEnd
                              , fragment:
                                  [ R.div
                                      { className: "flex-grow" }
                                  , Button.render
                                      { disabled: String.null email || String.null password
                                      , loading: submitting
                                      , onClick: sessions.login { email, password }
                                      , text: Ja.login
                                      }
                                  ]
                              }
                          ]
                      }
            }
  where
  renderInput :: String -> _ -> JSX
  renderInput label { type_, value, update } =
    Container.render
      { flex: Container.ColNoGap
      , fragment:
          [ R.label
              { className: "text-text-heading text-sm font-bold"
              , children: pure $ R.text label
              }
          , R.input
              { className:
                  "px-3 py-2 text-text-heading border border-divider"
                    <> " rounded appearance-none outline-none focus:ring"
              , type: type_
              , placeholder: label
              , value
              , onChange: capture targetValue $ traverse_ update
              }
          ]
      }
