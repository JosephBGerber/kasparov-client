module Main exposing (main)

import Array exposing (Array)
import Board exposing (Board)
import Browser
import GameState exposing (GameState)
import Html exposing (Html, button, div, input, table, td, text, tr)
import Html.Attributes exposing (class, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Move exposing (Move, Position)
import Msg exposing (Msg(..))
import Piece exposing (Piece)
import Player exposing (Player)
import Websocket



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type SocketStatus
    = Unopened
    | Connected
    | InstanceConnected
    | Closed Int


type Selection
    = None
    | First Position
    | Second Move


type alias Model =
    { status : SocketStatus
    , gameIdField : String
    , gameId : Maybe Int
    , state : GameState
    , player : Player
    , selection : Selection
    , board : Board
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { status = Unopened
      , gameIdField = ""
      , gameId = Nothing
      , state = GameState.Setup
      , player = Player.None
      , selection = None
      , board = Board.init
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SocketConnect ->
            ( { model | status = Connected }, Cmd.none )

        SocketInstanceConnected ->
            ( { model | status = InstanceConnected }, Cmd.none )

        SocketClosed unsentBytes ->
            ( { model | status = Closed unsentBytes }, Cmd.none )

        SocketError errMsg ->
            let
                _ =
                    Debug.log "Error:" errMsg
            in
            ( model, Cmd.none )

        BadMessage errMsg ->
            let
                _ =
                    Debug.log "Error:" errMsg
            in
            ( model, Cmd.none )

        SocketSetState state ->
            ( { model | state = state }
            , Cmd.none
            )

        SocketSetBoard board ->
            ( { model | board = board }
            , Cmd.none
            )

        SocketSetPlayer player ->
            ( { model | player = player }
            , Cmd.none
            )

        GameIdChanged gameIdField ->
            let
                gameId =
                    String.toInt gameIdField
            in
            ( { model | gameIdField = gameIdField, gameId = gameId }
            , Cmd.none
            )

        ConnectInstance ->
            case model.gameId of
                Nothing ->
                    ( model, Cmd.none )

                Just gameId ->
                    ( model
                    , Websocket.sendConnectInstance gameId
                    )

        Select position ->
            case model.selection of
                None ->
                    ( { model | selection = First position }
                    , Cmd.none
                    )

                First first ->
                    ( { model | selection = Second (Move first position) }
                    , Cmd.none
                    )

                Second _ ->
                    ( { model | selection = First position }
                    , Cmd.none
                    )

        SendMove ->
            case ( model.status, model.gameId, model.selection ) of
                ( InstanceConnected, Just gameId, Second move ) ->
                    ( { model | selection = None }, Websocket.sendMove gameId move )

                _ ->
                    ( { model | selection = None }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Websocket.events



-- VIEW


view : Model -> Html Msg
view model =
    case model.status of
        Unopened ->
            text "Connecting..."

        Connected ->
            viewConnected model

        InstanceConnected ->
            viewInstanceStarted model

        Closed _ ->
            viewInstanceStarted model


viewConnected : Model -> Html Msg
viewConnected model =
    div []
        [ input [ placeholder "Game PIN", value model.gameIdField, onInput GameIdChanged ] []
        , button [ onClick ConnectInstance ] [ text "Connect!" ]
        ]


viewInstanceStarted : Model -> Html Msg
viewInstanceStarted model =
    div [ style "display" "flex", style "justify-content" "center" ]
        [ div []
            [ viewBoard model.board
            , viewSocketStatus model.status
            , viewPlayer model.player
            , viewState model.state
            , viewSelection model.selection
            ]
        ]


viewSocketStatus : SocketStatus -> Html Msg
viewSocketStatus status =
    div []
        [ case status of
            Closed unsent ->
                div []
                    [ text " Closed with "
                    , text (String.fromInt unsent)
                    , text " bytes unsent."
                    ]

            _ ->
                div []
                    [ text "Connected! "
                    ]
        ]


viewState : GameState -> Html msg
viewState state =
    div [] [ text (GameState.toString state) ]


viewSelection : Selection -> Html Msg
viewSelection selection =
    case selection of
        None ->
            div []
                [ button [ onClick SendMove ] [ text "Send" ]
                , text "Nothing selected."
                ]

        First position ->
            div []
                [ button [ onClick SendMove ] [ text "Send" ]
                , text (Move.positionToFEN position)
                ]

        Second move ->
            div []
                [ button [ onClick SendMove ] [ text "Send" ]
                , text (Move.moveToFEN move)
                ]


viewPlayer : Player -> Html Msg
viewPlayer player =
    case player of
        Player.None ->
            div [] [ text "Team: " ]

        Player.Kasparov ->
            div [] [ text "Team: Kasparov" ]

        Player.World ->
            div [] [ text "Team: The World" ]


viewRow : ( Int, Array Piece ) -> Html Msg
viewRow ( rowIndex, row ) =
    let
        viewPiece y ( x, piece ) =
            let
                color =
                    if modBy 2 (y + x) == 0 then
                        "silver"

                    else
                        "white"
            in
            td [ onClick (Select (Position x y)), class "piece", style "background-color" color ] [ text (Piece.toString piece) ]
    in
    Array.toIndexedList row
        |> List.map (viewPiece rowIndex)
        |> tr []


viewBoard : Board -> Html Msg
viewBoard board =
    Array.toIndexedList board
        |> List.reverse
        |> List.map viewRow
        |> table [ class "board" ]
