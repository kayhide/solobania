module App.Soloban where

import AppPrelude
import Control.Monad.Rec.Class (Step(..), tailRecM)
import Control.Monad.Writer (WriterT, runWriterT, tell, lift)
import Data.Array as Array
import Data.Int as Int
import Effect.Random (randomInt, randomBool)

data Category
  = Shuzan
  | Anzan

derive instance genericCategory :: Generic Category _

instance eqCategory :: Eq Category where
  eq = genericEq

instance showCategory :: Show Category where
  show = genericShow

data Subject
  = Mitori (Array { digits :: Int /\ Int, lines :: Int, negative :: Boolean })
  | Kake (Array { lhs :: { digits :: Int /\ Int }, rhs :: { digits :: Int /\ Int }, lines :: Int })
  | Wari (Array { lhs :: { digits :: Int /\ Int }, rhs :: { digits :: Int /\ Int }, lines :: Int, divisible :: Boolean })

derive instance genericSubject :: Generic Subject _

instance eqSubject :: Eq Subject where
  eq = genericEq

instance showSubject :: Show Subject where
  show = genericShow

newtype Spec
  = Spec
  { category :: Category
  , label :: String
  , subjects :: Array (String /\ Subject)
  }

derive instance newtypeSpec :: Newtype Spec _

derive newtype instance eqSpec :: Eq Spec

derive newtype instance showSpec :: Show Spec

data Problem
  = MitoriProblem (Array { numbers :: Array Int })
  | KakeProblem (Array { left :: Int, right :: Int })
  | WariProblem (Array { left :: Int, right :: Int })

problemCount :: Problem -> Int
problemCount = case _ of
  MitoriProblem xs -> length xs
  KakeProblem xs -> length xs
  WariProblem xs -> length xs

shuzan_15 :: Spec
shuzan_15 =
  Spec
    { category: Shuzan
    , label: "第15級"
    , subjects:
        [ "見取算A"
            /\ Mitori
                ( Array.concat
                    [ replicate 5 { digits: 1 /\ 1, lines: 5, negative: true }
                    , replicate 5 { digits: 1 /\ 1, lines: 6, negative: true }
                    ]
                )
        , "見取算B"
            /\ Mitori
                ( Array.concat
                    [ replicate 5 { digits: 1 /\ 1, lines: 5, negative: true }
                    , replicate 5 { digits: 1 /\ 1, lines: 6, negative: true }
                    ]
                )
        ]
    }

generate :: Subject -> Effect Problem
generate = case _ of
  Mitori xs -> MitoriProblem <$> sequence (generateMitori <$> xs)
  Kake _ -> pure $ KakeProblem []
  Wari _ -> pure $ WariProblem []

generateMitori ::
  { digits :: Int /\ Int
  , lines :: Int
  , negative :: Boolean
  } ->
  Effect { numbers :: Array Int }
generateMitori { digits, lines, negative } = do
  _ /\ numbers <- runWriterT $ tailRecM go { n: lines, sum: 0 }
  pure { numbers }
  where
  go :: { n :: Int, sum :: Int } -> WriterT (Array Int) Effect (Step _ Unit)
  go = case _ of
    { n: 0, sum: _ } -> pure $ Done unit
    { n, sum } -> do
      let
        d0 /\ d1 = (Int.pow 10 <<< (_ - 1) *** (_ - 1) <<< Int.pow 10) digits
      x <-
        lift do
          case negative && (d0 < sum) of
            false -> randomInt d0 d1
            true -> do
              randomBool
                >>= case _ of
                    false -> randomInt d0 d1
                    true -> negate <$> randomInt (min sum d1) d0
      tell [ x ]
      pure $ Loop $ { n: n - 1, sum: sum + x }
