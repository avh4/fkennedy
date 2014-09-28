module Card where

import Dict
import Json

type Card = {
  question:String,
  choices:[String],
  start:Time,
  time:Int
}

parseUrl : String -> (Dict.Dict String Json.Value) -> String
parseUrl key d =
  let v = Dict.getOrElse (Json.String "BAD") key d
  in case v of
    Json.String s -> s
    _ -> "BAD"

parseString : Json.Value -> String
parseString v = case v of
  Json.String s -> s
  _ -> "STRANGE JSON"

parseStringArray : String -> (Dict.Dict String Json.Value) -> [String]
parseStringArray key d =
  let v = Dict.getOrElse (Json.Array []) key d
  in case v of
    Json.Array a -> map parseString a
    _ -> []

parseFloat : String -> (Dict.Dict String Json.Value) -> Float
parseFloat key d =
  let v = Dict.getOrElse (Json.Number 0) key d
  in case v of
    Json.Number f -> f
    _ -> 0

parseInt : String -> (Dict.Dict String Json.Value) -> Int
parseInt key d = floor <| parseFloat key d

toCard : Json.Value -> Maybe Card
toCard json = 
  case json of
    Json.Object c ->
      Just {
      question = parseUrl "question" c,
      choices = parseStringArray "choices" c,
      start = second * parseFloat "timeStamp" c,
      time = parseInt "time" c
      }
    _ -> Nothing
