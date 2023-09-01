module App.View.Organism.HistoryPanel where

import AppViewPrelude
import App.Data.Act (Act)
import App.Data.Pack (PackId)
import App.View.Agent.ActsAgent (useActsAgent)
import App.View.Agent.PacksAgent (usePacksAgent)
import App.View.Atom.Container as Container
import App.View.Atom.Value as Value
import App.Data.DateTime (printDateTime)
import Prim.Row as Row
import Data.Array as Array
import Data.Map as Map
import Data.Ord.Min (Min(..))
import Data.Ord.Max (Max(..))
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

render ::
  forall props props'.
  Row.Lacks "key" props =>
  Row.Lacks "children" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render = unsafePerformEffect make

def :: { | PropsRowOptional }
def = {}

make ::
  forall props props'.
  Row.Lacks "key" props =>
  Row.Lacks "children" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  Component { | props }
make =
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
  unsafePerformEffect
    $ component "Act" \(packId /\ acts) -> React.do
        packs <- usePacksAgent
        useEffect packId do
          packs.loadOne packId
          pure $ pure unit
        t0 /\ t1 <-
          useMemo acts \_ ->
            fold $ (Min <<< _.created_at &&& Max <<< _.updated_at) <<< unwrap <$> acts
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
              , fragment:
                  [ Value.render { text: name }
                  , Value.render { text: printDateTime $ coerce t0 }
                  , Value.render { text: printDateTime $ coerce t1 }
                  ]
              }
        pure
          $ R.div
              { className: "p-2 w-full"
              , children:
                  pure
                    $ maybe renderLoading renderItem packs.item
              }
