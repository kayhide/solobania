module App.View.Organism.HistoryPanel where

import AppViewPrelude
import App.Data.Act (Act)
import App.Data.DateTime (printDateTime)
import App.View.Agent.ActsAgent (useActsAgent)
import App.View.Atom.Container as Container
import App.View.Atom.Value as Value
import App.View.Sl as Sl
import Data.DateTime as DateTime
import Data.Time.Duration (Seconds)
import Data.Int as Int
import Data.String as String
import Prim.Row as Row
import React.Basic.DOM as R
import React.Basic.Hooks as React

type PropsRow :: forall k. Row k
type PropsRow
  = (
    | PropsRowOptional
    )

type PropsRowOptional :: forall k. Row k
type PropsRowOptional
  = (
    )

type Props
  = { | PropsRow }

def :: { | PropsRowOptional }
def = {}

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
    component "HistoryPanel" \_ -> React.do
      acts <- useActsAgent
      useEffect unit do
        acts.load
        pure $ pure unit
      pure
        $ Container.render
            { flex: Container.ColDense
            , padding: true
            , fullWidth: true
            , loading: acts.isLoading
            , fragment: renderAct <$> acts.items
            }

renderAct :: Act -> JSX
renderAct =
  renderComponent do
    component "Act" \act -> React.do
      let
        { display_name, created_at, updated_at } = unwrap act
      dt :: Seconds <-
        useMemo (created_at /\ updated_at) \_ ->
          DateTime.diff (updated_at) (created_at)
      pure
        $ R.div
            { className: "p-2 w-full"
            , children:
                pure
                  $ Container.render
                      { flex: Container.Row
                      , align: Container.AlignBaseline
                      , justify: Container.JustifyStretch
                      , fragment:
                          [ Value.render { text: display_name }
                          , Sl.format_date { lang: "ja", date: printDateTime $ coerce created_at }
                          -- , Sl.format_date { lang: "ja", date: printDateTime $ coerce t0, hour: "numeric", minute: "numeric", second: "numeric", "hour-format": "24" }
                          , Value.render
                              { text:
                                  (Int.round $ unwrap dt)
                                    # do
                                        min <- show <$> (_ `div` 60)
                                        sec <- show <$> (_ `mod` 60)
                                        pure $ min <> ":" <> bool identity (append "0") (String.length sec < 2) sec
                              }
                          ]
                      }
            }
