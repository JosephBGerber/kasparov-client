port module Websocket exposing (events, sendConnectInstance, sendMove)

import Board exposing (Board, decodeBoard)
import GameState exposing (GameState, decodeGameState)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Move exposing (Move)
import Msg exposing (Msg(..))
import Player exposing (Player, decodePlayer)



-- OUTBOUND


{-| Creates a standard message object structure for JS.
-}
message : String -> Int -> Value -> Value
message msgType gameID msg =
    Encode.object
        [ ( "msgType", Encode.string msgType )
        , ( "gameID", Encode.int gameID )
        , ( "msg", msg )
        ]


{-| Requests a move be sent out on the socket connection
-}
sendConnectInstance : Int -> Cmd msg
sendConnectInstance gameID =
    message
        "ConnectInstance"
        gameID
        (Encode.object
            []
        )
        |> toSocket


{-| Requests a move be sent out on the socket connection
-}
sendMove : Int -> Move -> Cmd msg
sendMove gameID move =
    let
        fen =
            Move.moveToFEN move
    in
    message
        "Move"
        gameID
        (Encode.object
            [ ( "move", Encode.string fen ) ]
        )
        |> toSocket



-- INBOUND


events : Sub Msg
events =
    fromSocket
        (\msg ->
            case Decode.decodeValue eventsDecoder msg of
                Ok value ->
                    value

                Err errorMsg ->
                    BadMessage (Decode.errorToString errorMsg)
        )


eventsDecoder : Decoder Msg
eventsDecoder =
    Decode.field "msgType" Decode.string
        |> Decode.andThen
            (\msgType ->
                case msgType of
                    "Connected" ->
                        Decode.succeed SocketConnect

                    "InstanceConnected" ->
                        Decode.succeed SocketInstanceConnected

                    "SetState" ->
                        Decode.map SocketSetState
                            (Decode.at [ "msg", "state" ] decodeGameState)

                    "SetBoard" ->
                        Decode.map SocketSetBoard
                            (Decode.at [ "msg", "board" ] decodeBoard)

                    "SetPlayer" ->
                        Decode.map SocketSetPlayer
                            (Decode.at [ "msg", "player" ] decodePlayer)

                    "Closed" ->
                        Decode.map SocketClosed
                            (Decode.at [ "msg", "unsentBytes" ] Decode.int)

                    "Error" ->
                        Decode.map SocketError
                            (Decode.at [ "msg", "event" ] Decode.string)

                    _ ->
                        Decode.succeed (BadMessage ("Unknown message type: " ++ msgType))
            )



-- PORTS


port toSocket : Value -> Cmd msg


port fromSocket : (Value -> a) -> Sub a
