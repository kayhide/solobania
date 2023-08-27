module App.Api.Endpoint where

import AppPrelude hiding ((/))
import App.Data.Id (ActId, PackId, ProblemId, SpecId)
import Data.Lens.Iso.Newtype (_Newtype)
import Routing.Duplex (RouteDuplex', int, prefix, root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

data Endpoint
  = Login
  | Specs
  | Spec SpecId
  | SpecPacks SpecId
  | Pack PackId
  | Acts
  | Act ActId
  | ProblemActs ProblemId

derive instance genericEndpoint :: Generic Endpoint _

instance showEndpoint :: Show Endpoint where
  show = genericShow

_id :: forall id. Newtype id Int => RouteDuplex' id
_id = _Newtype (int segment)

endpointCodec :: RouteDuplex' Endpoint
endpointCodec =
  root $ prefix "api"
    $ sum
        { "Login": "auth" / noArgs
        , "Specs": "specs" / noArgs
        , "Spec": "specs" / (_id :: RouteDuplex' SpecId)
        , "SpecPacks": "specs" / (_id :: RouteDuplex' SpecId) / "packs"
        , "Pack": "packs" / (_id :: RouteDuplex' PackId)
        , "Acts": "acts" / noArgs
        , "Act": "acts" / (_id :: RouteDuplex' ActId)
        , "ProblemActs": "problems" / (_id :: RouteDuplex' ProblemId) / "acts"
        }
