module App.View.Agent.FontAgent where

import AppViewPrelude
import App.Font (Font, LabelValue)
import React.Basic.Hooks as React

foreign import data UseFontAgent :: Type -> Type

useFontAgent :: Hook UseFontAgent Font
useFontAgent =
  unsafeCoerceHook React.do
    current /\ setCurrent <- useState "font-caveat"
    pure
      { current
      , set: setCurrent <<< const
      , options: fonts
      }

fonts :: Array LabelValue
fonts =
  [ { label: "Caveat", value: "font-caveat" }
  , { label: "Damion", value: "font-damion" }
  , { label: "Short Stack", value: "font-short-stack" }
  ]
