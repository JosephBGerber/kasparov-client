module Piece exposing (..)

import Json.Decode as Decode exposing (Decoder)


type Piece
    = BlackPawn
    | BlackKnight
    | BlackBishop
    | BlackRook
    | BlackQueen
    | BlackKing
    | WhitePawn
    | WhiteKnight
    | WhiteBishop
    | WhiteRook
    | WhiteQueen
    | WhiteKing
    | Empty


fromSAN : String -> Piece
fromSAN piece =
    case piece of
        "p" ->
            BlackPawn

        "n" ->
            BlackKnight

        "b" ->
            BlackBishop

        "r" ->
            BlackRook

        "q" ->
            BlackQueen

        "k" ->
            BlackKing

        "P" ->
            WhitePawn

        "N" ->
            WhiteKnight

        "B" ->
            WhiteBishop

        "R" ->
            WhiteRook

        "Q" ->
            WhiteQueen

        "K" ->
            WhiteKing

        " " ->
            Empty

        _ ->
            Debug.todo "Invalid FEN string"


toSAN : Piece -> String
toSAN piece =
    case piece of
        BlackPawn ->
            "p"

        BlackKnight ->
            "n"

        BlackBishop ->
            "b"

        BlackRook ->
            "r"

        BlackQueen ->
            "q"

        BlackKing ->
            "k"

        WhitePawn ->
            "P"

        WhiteKnight ->
            "N"

        WhiteBishop ->
            "B"

        WhiteRook ->
            "R"

        WhiteQueen ->
            "Q"

        WhiteKing ->
            "K"

        Empty ->
            " "


decodePiece : Decoder Piece
decodePiece =
    Decode.map fromSAN Decode.string
