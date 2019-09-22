module Msg exposing (..)

import Board exposing (Board)
import Player exposing (Player)
import GameState exposing (GameState)
import Move exposing (Position)


type Msg
    = SocketConnect
    | SocketClosed Int
    | SocketError String
    | SocketSetState GameState
    | SocketSetBoard Board
    | SocketSetPlayer Player
    | BadMessage String
    | Select Position
    | SendMove
