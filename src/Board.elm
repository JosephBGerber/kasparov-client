module Board exposing (Board, decodeBoard, init)

import Array exposing (Array)
import Json.Decode as Decode exposing (Decoder)
import Piece exposing (..)


type alias Board =
    Array (Array Piece)


init : Board
init =
    Array.initialize 8 (always (Array.initialize 8 (always Empty)))


decodeBoard : Decoder Board
decodeBoard =
    Decode.array (Decode.array decodePiece)
