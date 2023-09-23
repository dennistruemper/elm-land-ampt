module Pages.Home_ exposing (Model, Msg, page)

import Api.Counter exposing (Data, getNewCountFromMessage)
import Effect exposing (Effect)
import Html
import Html.Attributes
import Html.Events
import Http
import Page exposing (Page)
import Ports exposing (toElm)
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
    { countData : Data Int, count : Int, fromJS : Maybe String }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { countData = Api.Counter.Loading, count = 0, fromJS = Nothing }
    , Effect.sendCmd (Api.Counter.getCounter { onResponse = GotNewCountResponse, counterId = "global", baseUrl = shared.baseUrl })
    )



-- UPDATE


type Msg
    = Increment
    | Decrement
    | GotNewCountResponse (Result Http.Error Int)
    | ReceivedDataFromJavaScript String


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        Increment ->
            ( { model | countData = Api.Counter.Loading }
            , Effect.sendCmd <| Api.Counter.changeCounter { onResponse = GotNewCountResponse, counterId = "global", amount = 1, baseUrl = shared.baseUrl }
            )

        Decrement ->
            ( { model | countData = Api.Counter.Loading }
            , Effect.sendCmd <| Api.Counter.changeCounter { onResponse = GotNewCountResponse, counterId = "global", amount = -1, baseUrl = shared.baseUrl }
            )

        GotNewCountResponse countResult ->
            case countResult of
                Err error ->
                    ( { model | countData = Api.Counter.Failure error }
                    , Effect.none
                    )

                Ok count ->
                    ( { model | countData = Api.Counter.Success count, count = count }, Effect.none )

        ReceivedDataFromJavaScript dataFromJS ->
            let
                newCount =
                    case getNewCountFromMessage dataFromJS of
                        Nothing ->
                            model.count

                        Just countFromMessage ->
                            countFromMessage
            in
            ( { model | fromJS = Just dataFromJS, count = newCount }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    toElm ReceivedDataFromJavaScript



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        [ Html.div []
            [ Html.p [] [ Html.text "Keep this tab open and change value in an other Tab" ]
            , Html.div [] [ Html.button [ Html.Events.onClick Decrement ] [ Html.text "-" ] ]
            , case model.countData of
                Api.Counter.Loading ->
                    Html.div [] [ Html.text "Loading..." ]

                Api.Counter.Failure error ->
                    Html.div [] [ Html.text "Error" ]

                Api.Counter.Success count ->
                    Html.div [] [ Html.text <| String.fromInt model.count ]
            , Html.div []
                [ Html.button [ Html.Events.onClick Increment ] [ Html.text "+" ] ]
            , Html.p [] [ Html.text "This is an example project to show ", Html.a [ Html.Attributes.href "https://elm.land" ] [ Html.text "Elm-Land" ], Html.text " with ", Html.a [ Html.Attributes.href "https://getampt.com" ] [ Html.text "ampt" ], Html.text ". What may be of interest to you:" ]
            , Html.ul []
                [ Html.li [] [ Html.text "Ampt: express-js api - run ", Html.b [] [ Html.text "npx ampt" ], Html.text " to deploy your own sandbox" ]
                , Html.li [] [ Html.text "Ampt: test with temporary backend - run ", Html.b [] [ Html.text "npm run dev-test" ], Html.text " to create a temporary environment, execute data layer tests and destroy environment after" ]
                , Html.li [] [ Html.text "Ampt + Elm-Land: use websockets to notify other userers of change. Open multiple browsers / tabs, change the counter and see the change in other browsers/tabs. This feature is a separate commit so you can see all the chane in elm-land and ampt that is necessary" ]
                , Html.li [] [ Html.text "Ampt + Elm-Land: easy deployment I. Frontend and backend are at the same base URL, so you can call backend api with just the routes. Deployment does not need to know the URL of backend. Just needs to be inserted at local dev like this: ", Html.b [] [ Html.text "BASE_URL=https://your-nice.ampt.app npx elm-land server" ] ]
                , Html.li [] [ Html.text "Ampt + Elm-Land: easy deployment II. Build elm-land an copy output to /static directory. Run ampt deploy. Your project is live. ", Html.b [] [ Html.text "npm run deploy test" ], Html.text " You can name the stage other than test, maybe prod some day" ]
                , Html.br [] []
                , Html.br [] []
                , Html.br [] []
                , Html.br [] []
                , Html.p [ Html.Attributes.style "color" "red" ] [ Html.text "Just a DEMO, do not use theese settings for production." ]
                ]
            ]
        ]
    }
