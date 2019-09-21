module Main exposing (main)

import Board exposing (Board)
import Browser
import GameState exposing (GameState(..))
import Html exposing (Html, button, div, input, pre, text)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick, onInput)
import Msg exposing (Msg(..))
import Websocket

import Move exposing (Position, Move)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { socketInfo : SocketStatus
    , gameState : GameState
    , board : Board
    , toSend : String
    }


type SocketStatus
    = Unopened
    | Connected
    | Closed Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( { socketInfo = Unopened
      , gameState = Setup
      , board = Board.init
      , toSend = "ping!"
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketConnect ->
            ( { model | socketInfo = Connected }, Cmd.none )

        SocketClosed unsentBytes ->
            ( { model | socketInfo = Closed unsentBytes }, Cmd.none )

        SocketError errMsg ->
            let
                log =
                    Debug.log "Error:" errMsg
            in
            ( model, Cmd.none )

        BadMessage errMsg ->
            let
                log =
                    Debug.log "Error:" errMsg
            in
            ( model, Cmd.none )

        SocketSetState state ->
            let
                log =
                    Debug.log "State changed!"
            in
            ( model, Cmd.none )

        SocketSetBoard board ->
            ( { model | board = board }
            , Cmd.none
            )

        SendStringChanged string ->
                    ( { model | toSend = string }, Cmd.none )

        SendString ->
            let
                log =
                    Debug.log "Message sent:" model.toSend
            in
            case model.socketInfo of
                Connected ->
                    ( model, Websocket.sendString model.toSend )

                _ ->
                    ( model, Cmd.none )

        SendMove ->
            case model.socketInfo of
                Connected ->
                    ( model, Websocket.sendMove (Move (Position 2 1) (Position 3 2)) )

                _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Websocket.events



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ Board.view model.board
        , connectionState model
        , stringMsgControls model
        ]


connectionState : Model -> Html Msg
connectionState model =
    div [ class "connectionState" ]
        [ case model.socketInfo of
            Unopened ->
                text "Connecting..."

            Connected ->
                div []
                    [ text "Connected! "
                    ]

            Closed unsent ->
                div []
                    [ text " Closed with "
                    , text (String.fromInt unsent)
                    , text " bytes unsent."
                    ]
        ]


stringMsgControls : Model -> Html Msg
stringMsgControls model =
    div []
        [ div [ class "controls" ]
            [ button [ onClick SendMove ] [ text "Send" ]
            , input [ onInput SendStringChanged, value model.toSend ] []
            ]
        ]


messageInfo : String -> Html Msg
messageInfo message =
    div [] [ text message ]
