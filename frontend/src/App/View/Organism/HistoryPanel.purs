module App.View.Organism.HistoryPanel where

import AppViewPrelude
import App.Data (toId)
import App.Data.Act (Act)
import App.Data.DateTime (printDate)
import App.Data.Sheet (Sheet)
import App.View.Agent.ActsAgent (useActsAgent)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Atom.Container as Container
import App.View.Atom.Value as Value
import App.View.Sl as Sl
import Data.Array as Array
import Data.DateTime (Date, DateTime, date)
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
      dateActs <-
        useMemo acts.items \_ ->
          Map.fromFoldableWith (<>) ((toDate &&& pure) <$> acts.items)
      pure
        $ Container.render
            { flex: Container.Col
            , padding: true
            , fullWidth: true
            , loading: acts.isLoading
            , fragment: renderActs <$> Array.reverse (Map.toUnfoldable dateActs)
            }

toDate :: forall a r. Newtype a { created_at :: DateTime | r } => a -> Date
toDate = date <<< _.created_at <<< unwrap

renderActs :: (Date /\ Array Act) -> JSX
renderActs (date /\ acts) =
  Container.render
    { fragment:
        [ Sl.format_date { lang: "ja", date: printDate $ coerce date }
        , fragment $ renderAct <$> acts
        ]
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
        { pack_id, display_name } = unwrap act
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
      sheetTimeRanges <-
        useMemo acts.items \_ ->
          Map.fromFoldableWith append
            $ filterMap (\act' -> ((_ /\ toTimeRange act') <$> (unwrap act').sheet_id)) acts.items
      pure
        $ Container.render
            { flex: Container.RowNoGap
            , align: Container.AlignCenter
            , fragment:
                [ Container.render
                    { flex: Container.Row
                    , align: Container.AlignBaseline
                    , justify: Container.JustifyBetween
                    , someWidth: true
                    , fragment:
                        [ Value.render { dense: true, text: display_name }
                        , Value.render { dense: true, text: formatTimeRange (toTimeRange act) }
                        ]
                    }
                , Container.render
                    { flex: Container.ColNoGap
                    , fullWidth: true
                    , fragment:
                        [ Container.render
                            { flex: Container.RowDense
                            , fragment:
                                case sheets of
                                  [] -> [ renderFiller ]
                                  _ ->
                                    renderTimeRange 1800
                                      <$> (\sheet -> sheetTimeRanges ^? ix (toId sheet))
                                      <$> sheets
                            }
                        , Container.render
                            { flex: Container.RowDense
                            , fragment:
                                case sheets of
                                  [] -> [ renderFiller ]
                                  _ -> renderTimelimit 1800 <$> sheets
                            }
                        ]
                    }
                ]
            }

renderFiller :: JSX
renderFiller =
  R.span
    { className: "h-2 w-0 border border-transparent"
    }

renderTimeRange :: Int -> Maybe TimeRange -> JSX
renderTimeRange max range = do
  let
    dt = Int.round $ maybe 0.0 unwrap $ diffSeconds <$> range
  R.span
    { className: "h-2 bg-cyan-500 border border-cyan-200 rounded"
    , style: R.css { width: show (dt * 100 / max) <> "%" }
    , title: maybe "" formatTimeRange range
    }

renderTimelimit :: Int -> Sheet -> JSX
renderTimelimit max sheet = do
  let
    { timelimit } = unwrap sheet
  R.span
    { className: "h-2 bg-green-500 border border-green-200 rounded"
    , style: R.css { width: show (timelimit * 60 * 100 / max) <> "%" }
    , title: show timelimit <> ":00"
    }
