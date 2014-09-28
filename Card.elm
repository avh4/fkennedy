module Card where

import Dict
import Json
import Maybe

type Card = {
  question:String,
  choices:[String],
  start:Time,
  time:Int
}

unm : { question:Maybe String, choices:Maybe [String], start: Maybe Time, time:Maybe Int} -> Maybe Card
unm {question, choices, start, time} =
  case question of
    Nothing -> Nothing
    Just q -> case choices of
      Nothing -> Nothing
      Just c -> case start of
        Nothing -> Nothing
        Just s -> case time of
          Nothing -> Nothing
          Just t -> Just { question=q, choices=c, start=s, time=t }

parseUrl : String -> (Dict.Dict String Json.Value) -> Maybe String
parseUrl key d =
  let v = Dict.getOrElse (Json.Null) key d
  in case v of
    Json.String s -> Just s
    _ -> Nothing

parseString : Json.Value -> String
parseString v = case v of
  Json.String s -> s
  _ -> "STRANGE JSON"

parseStringArray : String -> (Dict.Dict String Json.Value) -> Maybe [String]
parseStringArray key d =
  let v = Dict.getOrElse (Json.Null) key d
  in case v of
    Json.Array a -> Just <| map parseString a
    _ -> Nothing

parseFloat : String -> (Dict.Dict String Json.Value) -> Maybe Float
parseFloat key d =
  let v = Dict.getOrElse (Json.Null) key d
  in case v of
    Json.Number f -> Just f
    _ -> Nothing

parseInt : String -> (Dict.Dict String Json.Value) -> Maybe Int
parseInt key d = Maybe.map floor <| parseFloat key d

toCard : Json.Value -> Maybe Card
toCard json = 
  case json of
    Json.Object c ->
      unm {
      question = parseUrl "question" c,
      choices = parseStringArray "choices" c,
      start = Maybe.map (\x -> second * x) <| parseFloat "timeStamp" c,
      time = parseInt "time" c
      }
    _ -> Nothing
