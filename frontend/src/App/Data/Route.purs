module App.Data.Route where

import AppPrelude hiding ((/))
import Routing.Duplex (RouteDuplex', root, segment)
import Routing.Duplex as Routing
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))
import Routing.Hash (setHash)

data Route
  = Home
  | Mitorizan
  | Shuzan String
  | Login
  | Logout

derive instance genericRoute :: Generic Route _

derive instance eqRoute :: Eq Route

derive instance ordRoute :: Ord Route

instance showRoute :: Show Route where
  show = genericShow

routeCodec :: RouteDuplex' Route
routeCodec =
  root
    $ sum
        { "Home": noArgs
        , "Mitorizan": "mitorizan" / noArgs
        , "Shuzan": "shuzan" / segment
        , "Login": "login" / noArgs
        , "Logout": "logout" / noArgs
        }

navigate :: forall m. MonadEffect m => Route -> m Unit
navigate route = liftEffect $ setHash $ Routing.print routeCodec route

hrefTo :: Route -> String
hrefTo route = "#" <> Routing.print routeCodec route
