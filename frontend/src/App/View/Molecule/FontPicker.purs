module App.View.Molecule.FontPicker where

import AppViewPrelude
import App.Context (context)
import App.View.Sl as Sl
import React.Basic.DOM as R
import React.Basic.Hooks as React

make :: Component {}
make =
  component "FontPicker" \_ -> React.do
    { font } <- useContext context
    pure
      $ Sl.select
          { value: font.current
          , className: "w-48"
          , onSlInput:
              capture targetValue \x -> do
                for_ x \x' -> font.set x'
          , children:
              font.options
                <#> \{ label, value } ->
                    Sl.option { label, value, children: [ R.text label ] }
          }

render :: {} -> JSX
render = unsafePerformEffect make
