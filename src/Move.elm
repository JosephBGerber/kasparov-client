module Move exposing (..)

import Json.Encode as Encode exposing (Value)


type alias Position =
    { col : Int
    , row : Int
    }


type alias Move =
    { from : Position
    , to : Position
    }


colToChar : Int -> Char
colToChar col =
    case col of
        0 ->
            'a'

        1 ->
            'b'

        2 ->
            'c'

        3 ->
            'd'

        4 ->
            'e'

        5 ->
            'f'

        6 ->
            'g'

        7 ->
            'h'

        _ ->
            Debug.todo "Invalid move index"


rowToChar : Int -> Char
rowToChar row =
    case row of
        0 ->
            '1'

        1 ->
            '2'

        2 ->
            '3'

        3 ->
            '4'

        4 ->
            '5'

        5 ->
            '6'

        6 ->
            '7'

        7 ->
            '8'

        _ ->
            Debug.todo "Invalid move index"


toFEN : Move -> String
toFEN move =
    let
        toCol =
            colToChar move.to.col

        toRow =
            rowToChar move.to.row

        fromCol =
            colToChar move.from.col

        fromRow =
            rowToChar move.from.row

        fen =
            [ fromCol, fromRow, toCol, toRow ]
    in
    String.fromList fen


encodeMove : Move -> Value
encodeMove move =
    Encode.object
        [ ( "move", Encode.string (toFEN move) ) ]
