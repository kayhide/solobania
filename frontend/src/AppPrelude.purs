module AppPrelude
  ( module Prelude
  , module Control.Alt
  , module Control.Alternative
  , module Control.Monad.Reader
  , module Control.Monad.Rec.Class
  , module Control.Plus
  , module Control.Monad.Writer
  , module Data.Argonaut
  , module Data.Array.NonEmpty
  , module Data.Bifunctor
  , module Data.Either
  , module Data.Either.Nested
  , module Data.Enum
  , module Data.Eq.Generic
  , module Data.Filterable
  , module Data.Foldable
  , module Data.Function
  , module Data.FunctorWithIndex
  , module Data.Generic.Rep
  , module Data.Lens
  , module Data.List
  , module Data.Map
  , module Data.Maybe
  , module Data.Monoid.Generic
  , module Data.Newtype
  , module Data.NonEmpty
  , module Data.Nullable
  , module Data.Ord.Generic
  , module Data.Profunctor.Strong
  , module Data.Semigroup.Generic
  , module Data.Set
  , module Data.Show.Generic
  , module Data.String.NonEmpty
  , module Data.Symbol
  , module Data.Traversable
  , module Data.TraversableWithIndex
  , module Data.Tuple
  , module Data.Tuple.Nested
  , module Data.Unfoldable
  , module Debug
  , module Effect
  , module Effect.Aff
  , module Effect.Aff.Class
  , module Effect.Class
  , module Effect.Exception
  , module Effect.Unsafe
  , module Foreign.Object
  , module Safe.Coerce
  , module Type.Proxy
  , module Unsafe.Coerce
  , bool
  , mmap
  ) where

import Prelude
import Control.Alt ((<|>))
import Control.Alternative (guard)
import Control.Monad.Reader (class MonadAsk, ReaderT, ask, asks, runReaderT)
import Control.Monad.Rec.Class (forever, whileJust, untilJust)
import Control.Plus (class Plus, empty)
import Control.Monad.Writer (Writer, tell, execWriter)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, jsonEmptyObject, jsonEmptyArray, jsonEmptyString, jsonParser, encodeJson, decodeJson)
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Bifunctor (bimap, lmap, rmap)
import Data.Either (Either(..), either, hush, isLeft, isRight, note)
import Data.Either.Nested (type (\/), (\/), in1, in2, in3, in4)
import Data.Enum (class Enum, class BoundedEnum, succ, pred, toEnum, fromEnum)
import Data.Eq.Generic (genericEq)
import Data.Filterable (compact, filter, filterMap, partition, partitionMap, eitherBool, maybeBool)
import Data.Foldable (class Foldable, all, and, any, elem, find, findMap, fold, foldM, foldl, foldr, foldMap, intercalate, length, maximum, maximumBy, minimum, minimumBy, notElem, or)
import Data.Function (on)
import Data.FunctorWithIndex (class FunctorWithIndex, mapWithIndex)
import Data.Generic.Rep (class Generic)
import Data.Lens ((%~), (.~), (^.), (^..), (^?))
import Data.List (List)
import Data.Map (Map)
import Data.Maybe (Maybe(..), maybe, isNothing, isJust, fromMaybe)
import Data.Monoid as Monoid
import Data.Monoid.Generic (genericMempty)
import Data.Newtype (class Newtype, wrap, unwrap)
import Data.NonEmpty (NonEmpty, (:|), fromNonEmpty)
import Data.Nullable (Nullable, null, notNull, toNullable)
import Data.Ord.Generic (genericCompare)
import Data.Profunctor.Strong ((***), (&&&))
import Data.Semigroup.Generic (genericAppend)
import Data.Set (Set)
import Data.Show.Generic (genericShow)
import Data.String.NonEmpty (NonEmptyString)
import Data.Symbol (class IsSymbol, reflectSymbol)
import Data.Traversable (class Traversable, for, for_, sequence, sequence_, traverse, traverse_)
import Data.TraversableWithIndex (class TraversableWithIndex, forWithIndex, traverseWithIndex)
import Data.Tuple (curry, fst, snd, swap, uncurry)
import Data.Tuple.Nested (type (/\), (/\))
import Data.Unfoldable (class Unfoldable, unfoldr, replicate, replicateA)
import Debug (trace, traceM, spy, spyWith)
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Exception (throw)
import Effect.Unsafe (unsafePerformEffect)
import Foreign.Object (Object)
import Safe.Coerce (coerce)
import Type.Proxy (Proxy(..))
import Unsafe.Coerce (unsafeCoerce)

bool :: forall a. a -> a -> Boolean -> a
bool x y b = if b then y else x

mmap :: forall a b. Monoid a => Monoid b => Eq a => (a -> b) -> a -> b
mmap f x = Monoid.guard (x /= mempty) $ f x
