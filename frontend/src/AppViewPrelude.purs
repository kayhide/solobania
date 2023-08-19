module AppViewPrelude
  ( module AppPrelude
  , module React.Basic.DOM.Events
  , module React.Basic.Events
  , module React.Basic.Hooks
  , module React.Basic.Hooks.Aff
  , unsafeCoerceHook
  , isEmptyJSX
  , zeroWidthSpace
  , unemptify
  ) where

import AppPrelude
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Data.String as String
import Data.String.CodePoints as CodePoints
import React.Basic.DOM.Events (capture, capture_, target, targetValue)
import React.Basic.Events (handler, handler_, merge)
import React.Basic.Hooks (Hook, JSX, Component, component, fragment, keyed, readRefMaybe, useContext, useEffect, useMemo, useReducer, useRef, useState)
import React.Basic.Hooks as Hooks
import React.Basic.Hooks.Aff (useAff)

unsafeCoerceHook ::
  forall startingHooks oldEndingHooks newEndingHooks a.
  Hooks.Render startingHooks oldEndingHooks a ->
  Hooks.Render startingHooks newEndingHooks a
unsafeCoerceHook = unsafeCoerce

isEmptyJSX :: JSX -> Boolean
isEmptyJSX jsx = isNothing $ Nullable.toMaybe (unsafeCoerce jsx :: Nullable Unit)

-- | Return zero width space.
-- | Useful to preserve the hight of a component based on the text height.
zeroWidthSpace :: String
zeroWidthSpace = maybe "" CodePoints.singleton $ toEnum 0x200B -- zero width space

-- | Return zero width space if given string is empty.
-- | Otherwise return the argument as is.
unemptify :: String -> String
unemptify = bool identity (const zeroWidthSpace) =<< String.null
