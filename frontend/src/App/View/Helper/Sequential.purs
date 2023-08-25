module App.View.Helper.Sequential where

import AppViewPrelude
import Data.Array as Array
import React.Basic.Hooks as React

type Sequential a
  = { current :: Maybe a
    , last :: Maybe a
    , isRunning :: Boolean
    , setAction :: (a -> Aff Unit) -> Effect Unit
    , clear :: Effect Unit
    , push :: a -> Effect Unit
    }

foreign import data UseSequential :: Type -> Type

useSequential ::
  forall a.
  Eq a =>
  Hook UseSequential (Sequential a)
useSequential =
  unsafeCoerceHook React.do
    action /\ setAction <- useState (const $ pure unit)
    current /\ setCurrent <- useState (Nothing :: Maybe a)
    last /\ setLast <- useState (Nothing :: Maybe a)
    items /\ setItems <- useState ([] :: Array a)
    useAff current do
      traverse_ action current
      liftEffect do
        setLast $ const current
        setCurrent $ const Nothing
    useEffect (current /\ items) do
      when (isNothing current) do
        for_ (Array.uncons items) \{ head, tail } -> do
          setCurrent $ const $ Just head
          setItems $ const tail
      pure $ pure unit
    pure
      { current
      , last
      , isRunning: isJust current || not (Array.null items)
      , setAction: setAction <<< const
      , clear: setItems $ const []
      , push: setItems <<< flip Array.snoc
      }
