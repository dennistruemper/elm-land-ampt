port module Ports exposing (..)


port fromElm : String -> Cmd msg


port toElm : (String -> msg) -> Sub msg
