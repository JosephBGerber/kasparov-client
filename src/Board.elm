module Board exposing (..)

import Array exposing (Array)
import Html exposing (Html, button, div, input, pre, text)
import Html.Attributes exposing (style)
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


view : Board -> Html msg
view board =
    let
        rowView row =
            List.foldl (\piece string -> string ++ Piece.toSAN piece) "" (Array.toList row)
    in
    Array.toList board
        |> List.reverse
        |> List.map rowView
        |> List.map text
        |> List.map (\row -> pre [ style "font-family" "'Lucida Console', Monaco, monospace", style "margin" "0", style "font-size" "3em" ] [ row ])
        |> div []
