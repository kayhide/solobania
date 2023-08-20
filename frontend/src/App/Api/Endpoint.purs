module App.Api.Endpoint where

import AppPrelude hiding ((/))
import Data.DateTime (DateTime)
import Data.Lens.Iso.Newtype (_Newtype)
import Data.RFC3339String (fromDateTime, toDateTime)
import Routing.Duplex (RouteDuplex', as, int, prefix, root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

dateTime :: RouteDuplex' String -> RouteDuplex' DateTime
dateTime = as print parse
  where
  print :: DateTime -> String
  print = unwrap <<< fromDateTime

  parse :: String -> Either String DateTime
  parse = note "Not a DateTime" <<< toDateTime <<< wrap

data Endpoint
  = Login

derive instance genericEndpoint :: Generic Endpoint _

instance showEndpoint :: Show Endpoint where
  show = genericShow

_id :: forall id. Newtype id Int => RouteDuplex' id
_id = _Newtype (int segment)

_sid :: forall id. Newtype id String => RouteDuplex' id
_sid = _Newtype segment

endpointCodec :: RouteDuplex' Endpoint
endpointCodec =
  root $ prefix "api"
    $ sum
        { "Login": "auth" / noArgs
        }
