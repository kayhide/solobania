module App.View.Molecule.NotificationList where

import AppViewPrelude
import App.Notification (Level(..), Notification(Notification))
import App.Context (context)
import Prim.Row as Row
import React.Basic.DOM as R
import React.Basic.Hooks as React
import Record as Record

type PropsRow
  = ( | PropsRowOptional )

type PropsRowOptional
  = ( className :: String
    )

type Props
  = { | PropsRow }

def :: { | PropsRowOptional }
def =
  { className: mempty
  }

render ::
  forall props props'.
  Row.Lacks "key" props =>
  Row.Lacks "children" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render =
  renderComponent do
    component "NotificationList" \props -> React.do
      let
        { className } = Record.merge props def :: Props
      { notifier } <- useContext context
      let
        renderItem (Notification id level msg) = do
          let
            color = case level of
              Info -> "bg-secondary-light"
              Warning -> "bg-warning-light"
              Error -> "bg-danger-light"
          R.div
            { className: color <> " bg-opacity-75 text-white py-3 px-5 my-2 rounded"
            , children: [ R.text msg ]
            , key: show id
            }
      pure
        $ R.div
            { className:
                "fixed top-0 inset-x-0 mx-auto mt-1 m-full max-w-2xl z-40"
                  <> (mmap (append " ") className)
            , children: map renderItem notifier.items
            }
