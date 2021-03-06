module GameState exposing (GameState(..), decodeGameState, toString)

import Json.Decode as Decode exposing (Decoder)


type GameState
    = Setup
    | White
    | Black
    | WhiteWins
    | BlackWins
    | Stalemate


decodeGameState : Decoder GameState
decodeGameState =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Setup" ->
                        Decode.succeed Setup

                    "White" ->
                        Decode.succeed White

                    "Black" ->
                        Decode.succeed Black

                    "WhiteWins" ->
                        Decode.succeed WhiteWins

                    "BlackWins" ->
                        Decode.succeed BlackWins

                    "Stalemate" ->
                        Decode.succeed Stalemate

                    _ ->
                        Debug.todo "Illegal game state received"
            )


toString : GameState -> String
toString state =
    case state of
        Setup ->
            "Setup"

        White ->
            "White"

        Black ->
            "Black"

        WhiteWins ->
            "WhiteWins"

        BlackWins ->
            "BlackWins"

        Stalemate ->
            "Stalemate"
