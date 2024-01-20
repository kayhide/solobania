{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "solobania-frontend"
, dependencies =
  [ "aff"
  , "affjax"
  , "affjax-web"
  , "argonaut"
  , "arrays"
  , "bifunctors"
  , "console"
  , "control"
  , "datetime"
  , "debug"
  , "effect"
  , "either"
  , "enums"
  , "exceptions"
  , "filterable"
  , "foldable-traversable"
  , "foreign-object"
  , "formatters"
  , "http-methods"
  , "integers"
  , "js-date"
  , "js-timers"
  , "lists"
  , "maybe"
  , "newtype"
  , "nonempty"
  , "now"
  , "nullable"
  , "numbers"
  , "ordered-collections"
  , "orders"
  , "precise-datetime"
  , "prelude"
  , "profunctor"
  , "profunctor-lenses"
  , "psci-support"
  , "random"
  , "react-basic"
  , "react-basic-dom"
  , "react-basic-hooks"
  , "record"
  , "routing"
  , "routing-duplex"
  , "safe-coerce"
  , "strings"
  , "tailrec"
  , "transformers"
  , "tuples"
  , "unfoldable"
  , "unsafe-coerce"
  , "unsafe-reference"
  , "web-dom"
  , "web-events"
  , "web-file"
  , "web-html"
  , "web-storage"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
