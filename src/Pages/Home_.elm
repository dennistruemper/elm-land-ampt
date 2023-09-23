module Pages.Home_ exposing (Model, Msg, page)

import Api.Counter exposing (Data)
import Effect exposing (Effect)
import Html
import Html.Events
import Http
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { countData : Data Int, count : Int }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { countData = Api.Counter.Loading, count = 0 }
    , Effect.sendCmd (Api.Counter.getCounter { onResponse = GotNewCountResponse, counterId = "test", baseUrl = shared.baseUrl })
    )



-- UPDATE


type Msg
    = Increment
    | Decrement
    | GotNewCountResponse (Result Http.Error Int)


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        Increment ->
            ( model
            , Effect.sendCmd <| Api.Counter.changeCounter { onResponse = GotNewCountResponse, counterId = "test", amount = 1, baseUrl = shared.baseUrl }
            )

        Decrement ->
            ( model
            , Effect.sendCmd <| Api.Counter.changeCounter { onResponse = GotNewCountResponse, counterId = "test", amount = -1, baseUrl = shared.baseUrl }
            )

        GotNewCountResponse countResult ->
            case countResult of
                Err error ->
                    ( { model | countData = Api.Counter.Failure error }
                    , Effect.none
                    )

                Ok count ->
                    ( { model | countData = Api.Counter.Success count, count = count }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        [ Html.div []
            [ Html.div [] [ Html.button [ Html.Events.onClick Decrement ] [ Html.text "-" ] ]
            , case model.countData of
                Api.Counter.Loading ->
                    Html.div [] [ Html.text "Loading..." ]

                Api.Counter.Failure error ->
                    Html.div [] [ Html.text "Error" ]

                Api.Counter.Success count ->
                    Html.div [] [ Html.text "Loaded" ]
            , Html.div [] [ Html.text (String.fromInt model.count) ]
            , Html.div [] [ Html.button [ Html.Events.onClick Increment ] [ Html.text "+" ] ]
            ]
        ]
    }
