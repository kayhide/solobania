module App.View.Molecule.Dropdown where

import AppViewPrelude
import Prim.Row as Row
import React.Basic.DOM as R
import React.Basic.Hooks as React
import Record as Record

type PropsRow
  = ( content :: JSX
    | PropsRowOptional
    )

data Align
  = AlignLeft
  | AlignRight

derive instance eqAlign :: Eq Align

derive instance ordAlign :: Ord Align

type PropsRowOptional
  = ( className :: String
    , trigger :: Effect Unit -> JSX
    , align :: Align
    , open :: Boolean
    )

type Props
  = { | PropsRow }

make ::
  forall props props'.
  Row.Lacks "key" props =>
  Row.Lacks "children" props =>
  Row.Lacks "ref" props =>
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  Component { | props }
make = do
  let
    def =
      { className: mempty
      , trigger: const mempty
      , align: AlignLeft
      , open: false
      } ::
        { | PropsRowOptional }
  component "Dropdown" \props -> React.do
    let
      { className, trigger, content, align, open } = Record.merge props def :: Props
    open /\ setOpen <- useState false
    closing /\ setClosing <- useState false
    -- If it did not regain a focus in a same event handling cycle,
    -- the focus actually went somewhere out of the component.
    useAff closing do
      when closing do
        delay $ Milliseconds 0.0
        liftEffect do
          setOpen $ const $ false
    pure
      $ R.div
          { className:
              "relative"
                <> mmap (append " ") className
          , onBlur: handler_ $ setClosing $ const true
          , onFocus: handler_ $ setClosing $ const false
          , children:
              [ trigger $ setOpen not
              , R.div
                  { className:
                      "absolute z-20 bottom-0 transform translate-y-full transition-visibility duration-200"
                        <> (bool " invisible opacity-0" "" open)
                        <> (bool "" " right-0" (align == AlignRight))
                  , children: pure content
                  }
              ]
          }
