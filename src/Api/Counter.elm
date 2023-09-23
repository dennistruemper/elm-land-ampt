module Api.Counter exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode


type Data value
    = Loading
    | Success value
    | Failure Http.Error


counterDecoder : Decode.Decoder Int
counterDecoder =
    Decode.field "count" Decode.int


getCounter : { onResponse : Result Http.Error Int -> msg, counterId : String, baseUrl : String } -> Cmd msg
getCounter options =
    Http.get
        { url = options.baseUrl ++ "/counter/" ++ options.counterId
        , expect = Http.expectJson options.onResponse counterDecoder
        }


changeCounter : { onResponse : Result Http.Error Int -> msg, counterId : String, baseUrl : String, amount : Int } -> Cmd msg
changeCounter options =
    Http.post
        { url = options.baseUrl ++ "/counter/" ++ options.counterId
        , body = Http.jsonBody <| Encode.object [ ( "amount", Encode.int options.amount ) ]
        , expect = Http.expectJson options.onResponse counterDecoder
        }
