module App.View.Organism.HistoryPanel where

import AppViewPrelude
import App.Data.Act (Act)
import App.Data.DateTime (printDateTime)
import App.Data.Pack (PackId)
import App.View.Agent.ActsAgent (useActsAgent)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Atom.Container as Container
import App.View.Atom.Value as Value
import App.View.Sl as Sl
import Data.Array as Array
import Data.DateTime as DateTime
import Data.Map as Map
import Data.Ord.Max (Max(..))
import Data.Ord.Min (Min(..))
import Data.Time.Duration (Seconds)
import Data.Int as Int
import Data.String as String
import Prim.Row as Row
import Data.Number.Format (toStringWith, fixed)
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
      items <-
        useMemo acts.items \_ ->
          Map.fromFoldableWith (<>)
            $ ((_.pack_id <<< unwrap) &&& pure)
            <$> acts.items
      pure
        $ Container.render
            { flex: Container.ColDense
            , padding: true
            , fullWidth: true
            , loading: acts.isLoading
            , fragment:
                renderAct
                  <$> Array.take 5 do
                      packId /\ v <- Array.reverse $ Map.toUnfoldable items
                      maybe [] (pure <<< (_ /\ v)) packId
            }

renderAct :: PackId /\ Array Act -> JSX
renderAct =
  renderComponent do
    component "Act" \(packId /\ acts) -> React.do
      packs <- usePacksAgent
      useEffect packId do
        packs.loadOne packId
        pure $ pure unit
      t0 /\ t1 <-
        useMemo acts \_ ->
          fold $ (Min <<< _.created_at &&& Max <<< _.updated_at) <<< unwrap <$> acts
      dt :: Seconds <-
        useMemo (t0 /\ t1) \_ ->
          DateTime.diff (coerce t1) (coerce t0)
      let
        renderLoading =
          Container.render
            { fullWidth: true
            , loading: true
            , content: R.text zeroWidthSpace
            }

        renderItem pack = do
          let
            { name } = unwrap pack
          Container.render
            { flex: Container.Row
            , align: Container.AlignBaseline
            , justify: Container.JustifyStretch
            , fragment:
                [ Value.render { text: name }
                , Sl.format_date { lang: "ja", date: printDateTime $ coerce t0 }
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
      pure
        $ R.div
            { className: "p-2 w-full"
            , children:
                pure
                  $ maybe renderLoading renderItem packs.item
            }
