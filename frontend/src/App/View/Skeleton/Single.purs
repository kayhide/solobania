module App.View.Skeleton.Single where

import AppViewPrelude
import App.View.Molecule.NotificationList as NotificationList
import Prim.Row as Row
import React.Basic.DOM as R
import Record as Record

data Layout
  = Narrow
  | Wide

type PropsRow
  = ( alpha :: JSX
    , layout :: Layout
    | PropsRowOptional
    )

type PropsRowOptional
  = ( className :: String
    , omega :: JSX
    , header :: JSX
    , footer :: JSX
    )

type Props
  = { | PropsRow }

make ::
  forall props props'.
  Row.Lacks "children" props =>
  Row.Lacks "key" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  Component (Record props)
make = do
  notificationList <- NotificationList.make
  component "Single" \props -> React.do
    let
      def = { className: "", omega: mempty, header: mempty, footer: mempty } :: { | PropsRowOptional }

      { alpha, layout, className, omega, header, footer } = Record.merge props def :: Props

      width = case layout of
        Narrow -> "w-full max-w-md"
        Wide -> "w-full max-w-6xl"
    pure
      $ R.div
          { className:
              "flex flex-col w-screen h-screen bg-background-primary"
                <> mmap (append " ") className
          , children:
              [ header
              , R.div
                  { className: "w-full flex-grow overflow-y-hidden"
                  , children:
                      [ R.div
                          { className: "h-full flex mx-auto " <> width
                          , children:
                              [ R.div
                                  { className: "w-full h-full relative"
                                  , children: pure alpha
                                  }
                              ]
                          }
                      , omega
                      ]
                  }
              , footer
              , notificationList {}
              ]
          }
