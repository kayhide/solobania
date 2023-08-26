module App.View.Atom.Container where

import AppViewPrelude hiding (Either(..))
import App.View.Atom.LoadingIcon as LoadingIcon
import Data.Monoid as Monoid
import Data.Nullable as Nullable
import Prim.Row as Row
import React.Basic.DOM as R
import Record as Record

data AbsolutePosition
  = Fill
  | Top
  | Bottom
  | Left
  | Right
  | TopLeft
  | TopRight
  | BottomLeft
  | BottomRight

data Flex
  = Row
  | RowDense
  | RowNoGap
  | RowWrapping
  | Col
  | ColDense
  | ColNoGap

data Grid
  = GridCols Int

data Align
  = AlignBaseline
  | AlignCenter

data Justify
  = JustifyStart
  | JustifyCenter
  | JustifyEnd
  | JustifyBetween

data Translate
  = TranslateXFull
  | TranslateYFull

type PropsRow
  = (
    | PropsRowOptional
    )

type PropsRowOptional
  = ( content :: JSX
    , fragment :: Array JSX
    , padding :: Boolean
    , fullHeight :: Boolean
    , fullWidth :: Boolean
    , someWidth :: Boolean
    , nonInteractive :: Boolean
    , position :: AbsolutePosition
    , visible :: Boolean
    , flex :: Flex
    , grid :: Grid
    , align :: Align
    , justify :: Justify
    , translate :: Translate
    , loading :: Boolean
    )

type Props
  = { | PropsRow }

def :: { | PropsRowOptional }
def =
  { content: mempty
  , fragment: []
  , padding: false
  , fullHeight: false
  , fullWidth: false
  , someWidth: false
  , nonInteractive: false
  , position: unsafeCoerce unit
  , visible: unsafeCoerce unit
  , flex: unsafeCoerce unit
  , grid: unsafeCoerce unit
  , align: unsafeCoerce unit
  , justify: unsafeCoerce unit
  , translate: unsafeCoerce unit
  , loading: unsafeCoerce unit
  }

render ::
  forall props props'.
  Row.Union props PropsRowOptional props' =>
  Row.Nub props' PropsRow =>
  { | props } -> JSX
render props = do
  let
    { content
    , fragment
    , padding
    , fullHeight
    , fullWidth
    , someWidth
    , nonInteractive
    } = Record.merge props def :: Props

    position = Nullable.toMaybe (unsafeCoerce props).position

    visible = Nullable.toMaybe (unsafeCoerce props).visible

    flex = Nullable.toMaybe (unsafeCoerce props).flex

    grid = Nullable.toMaybe (unsafeCoerce props).grid

    align = Nullable.toMaybe (unsafeCoerce props).align

    justify = Nullable.toMaybe (unsafeCoerce props).justify

    translate = Nullable.toMaybe (unsafeCoerce props).translate

    loading = Nullable.toMaybe (unsafeCoerce props).loading

    positionClass =
      maybe "relative" ("absolute " <> _)
        $ position
        <#> case _ of
            Fill -> "inset-0"
            Top -> "inset-x-0 top-0"
            Bottom -> "inset-x-0 bottom-0"
            Left -> "inset-y-0 left-0"
            Right -> "inset-y-0 right-0"
            TopLeft -> "top-0 left-0"
            TopRight -> "top-0 right-0"
            BottomLeft -> "bottom-0 left-0"
            BottomRight -> "bottom-0 right-0"

    visibleClass =
      maybe "" ("transition duration-200 " <> _)
        $ visible
        <#> bool "opacity-0 pointer-events-none select-none" ""

    flexClass =
      maybe "" (append "flex" <<< mmap (append " "))
        $ flex
        <#> case _ of
            Row -> "space-x-4"
            RowDense -> "space-x-1"
            RowNoGap -> ""
            RowWrapping -> "flex-wrap"
            Col -> "flex-col space-y-4"
            ColDense -> "flex-col space-y-1"
            ColNoGap -> "flex-col"

    gridClass =
      maybe "" ("grid " <> _)
        $ grid
        <#> case _ of
            GridCols n -> " grid-cols-" <> show n <> " gap-4"

    alignClass =
      fromMaybe ""
        $ align
        <#> case _ of
            AlignBaseline -> "items-baseline"
            AlignCenter -> "items-center"

    justifyClass =
      fromMaybe ""
        $ justify
        <#> case _ of
            JustifyStart -> "justify-start"
            JustifyCenter -> "justify-center"
            JustifyEnd -> "justify-end"
            JustifyBetween -> "justify-between"

    translateClass =
      fromMaybe ""
        $ translate
        <#> case _ of
            TranslateXFull -> "translate-x-full"
            TranslateYFull -> "translate-y-full"
  R.div
    { className:
        positionClass
          <> mmap (append " ") visibleClass
          <> mmap (append " ") flexClass
          <> mmap (append " ") gridClass
          <> mmap (append " ") alignClass
          <> mmap (append " ") justifyClass
          <> mmap (append " transform ") translateClass
          <> bool "" " p-4" padding
          <> bool "" " h-full" fullHeight
          <> bool "" " w-full" fullWidth
          <> bool "" " w-64" someWidth
          <> bool "" " pointer-events-none" nonInteractive
    , children:
        [ content ]
          <> fragment
          <> [ Monoid.guard (isJust loading)
                $ R.div
                    { className: "absolute inset-x-0 top-0 h-36 pointer-events-none select-none"
                    , children:
                        pure
                          $ LoadingIcon.render
                              { active: Just true == loading
                              , size: LoadingIcon.Large
                              }
                    }
            ]
    }
