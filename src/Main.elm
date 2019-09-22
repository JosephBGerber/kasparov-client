module Main exposing (main)

import Array exposing (Array)
import Board exposing (Board)
import Player exposing (Player)
import Browser
import GameState exposing (GameState)
import Html exposing (Html, button, div, span, text, table, tr, td)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Move exposing (Move, Position)
import Msg exposing (Msg(..))
import Piece exposing (Piece)
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


type alias Model =
    { socketInfo : SocketStatus
    , state : GameState
    , selection : Selection
    , board : Board
    , player : Player
    }


type SocketStatus
    = Unopened
    | Connected
    | Closed Int


type Selection
    = None
    | First Position
    | Second Move


init : () -> ( Model, Cmd Msg )
init _ =
    ( { socketInfo = Unopened
      , state = GameState.Setup
      , selection = None
      , board = Board.init
      , player = Player.None
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
            case ( model.socketInfo, model.selection ) of
                ( Connected, Second move ) ->
                    ( { model | selection = None }, Websocket.sendMove move )

                _ ->
                    ( { model | selection = None }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Websocket.events



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewBoard model.board
        , viewSocketStatus model.socketInfo
        , viewPlayer model.player
        , viewState model.state
        , viewSelection model.selection
        ]


viewSocketStatus : SocketStatus -> Html Msg
viewSocketStatus status =
    div []
        [ case status of
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
                    if (modBy 2 (y + x)  == 0) then
                        "silver"
                    else
                        "white"
            in
            td [ onClick (Select (Position x y)), style "width" "1.5em", style "height" "1.5em", style "background-color" color, style "text-align" "center", style "border-collapse" "collapse" ] [ text (Piece.toString piece) ]
    in
    Array.toIndexedList row
        |> List.map (viewPiece rowIndex)
        |> tr []


viewBoard : Board -> Html Msg
viewBoard board =
    Array.toIndexedList board
        |> List.reverse
        |> List.map viewRow
        |> table [ style "font-family" "'Lucida Console', Monaco, monospace", style "margin" "0", style "font-size" "3em", style "border-spacing" "0pt" ]
