module Msg exposing (..)

import Board exposing (Board)
import GameState exposing (GameState)
import Move exposing (Position)
import Player exposing (Player)


type Msg
    = SocketConnect
    | SocketInstanceConnected
    | SocketClosed Int
    | SocketError String
    | SocketSetState GameState
    | SocketSetBoard Board
    | SocketSetPlayer Player
    | BadMessage String
    | GameIdChanged String
    | ConnectInstance
    | Select Position
    | SendMove
