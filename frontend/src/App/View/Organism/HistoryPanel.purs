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
formatTimeRange = formatSeconds <<< diffSeconds

formatSeconds :: Seconds -> String
formatSeconds seconds =
  Int.round (unwrap seconds)
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
      sheetDurations <-
        useMemo acts.items \_ ->
          map diffSeconds
            $ Map.fromFoldableWith append
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
                                uncurry (renderDuration 1800)
                                  <$> (\sheet -> sheet /\ (sheetDurations ^? ix (toId sheet)))
                                  <$> sheets
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

renderDuration :: Int -> Sheet -> Maybe Seconds -> JSX
renderDuration max sheet seconds = do
  let
    { timelimit } = unwrap sheet

    dt = Int.round $ maybe 0.0 unwrap seconds
  renderBar
    { variation: bool InTime OverTime $ timelimit * 60 < dt
    , value: dt * 100 / max
    , text: maybe "" formatSeconds seconds
    }

renderTimelimit :: Int -> Sheet -> JSX
renderTimelimit max sheet = do
  let
    { timelimit } = unwrap sheet
  renderBar
    { variation: Neutral
    , value: timelimit * 60 * 100 / max
    , text: show timelimit <> ":00"
    }

data BarVariation
  = Neutral
  | InTime
  | OverTime

type BarArgs
  = { variation :: BarVariation
    , value :: Int
    , text :: String
    }

renderBar :: BarArgs -> JSX
renderBar { variation, value, text } = do
  let
    colorClass = case variation of
      Neutral -> "bg-gray-500 border-gray-200"
      InTime -> "bg-green-500 border-green-200"
      OverTime -> "bg-red-500 border-red-200"
  R.span
    { className: "h-2 border rounded " <> colorClass
    , style: R.css { width: show value <> "%" }
    , title: text
    }
