module App.View.Organism.HistoryPanel where

import AppViewPrelude
import App.Data (toId)
import App.Data.Act (Act)
import App.Data.DateTime (printDateTime)
import App.Data.Sheet (Sheet)
import App.View.Agent.ActsAgent (useActsAgent)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Atom.Container as Container
import App.View.Atom.Value as Value
import App.View.Sl as Sl
import Data.DateTime (DateTime)
import Data.DateTime as DateTime
import Data.Int as Int
import Data.Lens.Index (ix)
import Data.Map as Map
import Data.Newtype (class Newtype)
import Data.Ord.Max (Max(..))
import Data.Ord.Min (Min(..))
import Data.String as String
import Data.Time.Duration (Seconds)
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

type TimeRange
  = Min DateTime /\ Max DateTime

toTimeRange :: forall a r. Newtype a { created_at :: DateTime, updated_at :: DateTime | r } => a -> TimeRange
toTimeRange = (Min <<< _.created_at &&& Max <<< _.updated_at) <<< unwrap

diffSeconds :: TimeRange -> Seconds
diffSeconds = uncurry DateTime.diff <<< (coerce *** coerce) <<< swap

formatTimeRange :: TimeRange -> String
formatTimeRange range =
  (Int.round $ unwrap $ diffSeconds range)
    # do
        min <- show <$> (_ `div` 60)
        sec <- show <$> (_ `mod` 60)
        pure $ min <> ":" <> bool identity (append "0") (String.length sec < 2) sec

renderAct :: Act -> JSX
renderAct =
  renderComponent do
    component "Act" \act -> React.do
      let
        { pack_id, display_name, created_at } = unwrap act
      acts <- useActsAgent
      packs <- usePacksAgent
      useEffect pack_id do
        for_ pack_id \id' -> do
          acts.setPackId id'
          acts.load
          packs.loadOne id'
        pure $ pure unit
      sheets <-
        useMemo packs.item \_ ->
          maybe [] (unwrap >>> _.sheets) packs.item
      timelimit <-
        useMemo sheets \_ ->
          foldl (+) 0 $ (unwrap >>> _.timelimit) <$> sheets
      sheetTimeRanges <-
        useMemo acts.items \_ ->
          Map.fromFoldableWith append
            $ filterMap (\act' -> ((_ /\ toTimeRange act') <$> (unwrap act').sheet_id)) acts.items
      pure
        $ Container.render
            { flex: Container.ColNoGap
            , content:
                Container.render
                  { flex: Container.ColNoGap
                  , fragment:
                      [ Container.render
                          { flex: Container.Row
                          , align: Container.AlignBaseline
                          , justify: Container.JustifyStretch
                          , fragment:
                              [ Sl.format_date { lang: "ja", date: printDateTime $ coerce created_at }
                              , Value.render { text: display_name }
                              , Value.render
                                  { text:
                                      formatTimeRange (toTimeRange act)
                                        # bool identity (_ <> (" / " <> show timelimit <> ":00")) (0 < timelimit)
                                  }
                              ]
                          }
                      , Container.render
                          { flex: Container.ColNoGap
                          , fragment:
                              [ Container.render
                                  { flex: Container.RowDense
                                  , fragment:
                                      renderTimeRange 1800 <$> (\sheet -> sheetTimeRanges ^? ix (toId sheet)) <$> sheets
                                  }
                              , Container.render
                                  { flex: Container.RowDense
                                  , fragment:
                                      renderTimelimit 1800 <$> sheets
                                  }
                              ]
                          }
                      ]
                  }
            }

renderTimeRange :: Int -> Maybe TimeRange -> JSX
renderTimeRange max =
  renderComponent do
    component "TimeRange" \range -> React.do
      let
        dt = Int.round $ maybe 0.0 unwrap $ diffSeconds <$> range
      pure
        $ R.span
            { className: "h-2 bg-cyan-500 border border-cyan-200 rounded"
            , style: R.css { width: show (dt * 100 / max) <> "%" }
            }

renderTimelimit :: Int -> Sheet -> JSX
renderTimelimit max =
  renderComponent do
    component "Timelimit" \sheet -> React.do
      let
        { timelimit } = unwrap sheet
      pure
        $ R.span
            { className: "h-2 bg-green-500 border border-green-200 rounded"
            , style: R.css { width: show (timelimit * 60 * 100 / max) <> "%" }
            }
