module Player exposing (Player(..), decodePlayer)

import Json.Decode as Decode exposing (Decoder)


type Player
    = Kasparov
    | World
    | None


decodePlayer : Decoder Player
decodePlayer =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Kasparov" ->
                        Decode.succeed Kasparov

                    "World" ->
                        Decode.succeed World

                    _ ->
                        Debug.todo "Illegal player type received"
            )
