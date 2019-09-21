port module Websocket exposing (events, sendString, sendMove)

import GameState exposing (GameState, decodeGameState)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Move exposing (Move)
import Board exposing (Board, decodeBoard)
import Msg exposing (Msg(..))



-- OUTBOUND


{-| Creates a standard message object structure for JS.
-}
message : String -> Value -> Value
message msgType msg =
    Encode.object
        [ ( "msgType", Encode.string msgType )
        , ( "msg", msg )
        ]


{-| Requests a string to be sent out on the socket connection.
-}
sendString : String -> Cmd msg
sendString text =
    message "SendString"
        (Encode.object
            [ ( "message", Encode.string text ) ]
        )
        |> toSocket


{-| Requests a move be sent out on the socket connection
-}
sendMove : Move -> Cmd msg
sendMove move =
    let
        fen =
            Move.toFEN move
    in
    message "SendMove"
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

                    "SetState" ->
                        Decode.map SocketSetState
                            (Decode.at [ "msg", "state" ] decodeGameState)

                    "SetBoard" ->
                        Decode.map SocketSetBoard
                            (Decode.at [ "msg", "board" ] decodeBoard)

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
