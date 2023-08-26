module App.Data.Route where

import AppPrelude hiding ((/))
import App.Data.Id (PackId)
import Data.Lens.Iso.Newtype (_Newtype)
import Routing.Duplex (RouteDuplex', int, root, segment)
import Routing.Duplex as Routing
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))
import Routing.Hash (setHash)

data Route
  = Home
  | Login
  | Logout
  | Mitorizan
  | Shuzan String
  | Pack PackId

derive instance genericRoute :: Generic Route _

derive instance eqRoute :: Eq Route

derive instance ordRoute :: Ord Route

instance showRoute :: Show Route where
  show = genericShow

_id :: forall id. Newtype id Int => RouteDuplex' id
_id = _Newtype (int segment)

routeCodec :: RouteDuplex' Route
routeCodec =
  root
    $ sum
        { "Home": noArgs
        , "Login": "login" / noArgs
        , "Logout": "logout" / noArgs
        , "Mitorizan": "mitorizan" / noArgs
        , "Shuzan": "shuzan" / segment
        , "Pack": "packs" / (_id :: RouteDuplex' PackId)
        }

navigate :: forall m. MonadEffect m => Route -> m Unit
navigate route = liftEffect $ setHash $ Routing.print routeCodec route

hrefTo :: Route -> String
hrefTo route = "#" <> Routing.print routeCodec route
