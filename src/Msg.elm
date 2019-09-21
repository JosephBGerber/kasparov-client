module Msg exposing (..)

import Board exposing (Board)
import GameState exposing (GameState)


type Msg
    = SocketConnect
    | SocketClosed Int
    | SocketError String
    | SocketSetState GameState
    | SocketSetBoard Board
    | BadMessage String
    | SendStringChanged String
    | SendString
    | SendMove
