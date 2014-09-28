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

parseString : Json.Value -> Maybe String
parseString v = case v of
  Json.String s -> Just s
  _ -> Nothing

p : String -> (Json.Value -> Maybe a) -> (Dict.Dict String Json.Value) -> Maybe a
p key fn d = case (Dict.get key d) of
  Just v -> fn v
  Nothing -> Nothing

parseStringArray : Json.Value -> Maybe [String]
parseStringArray v = case v of
  Json.Array a -> Just <| filterMap identity <| map parseString a
  _ -> Nothing

parseFloat : Json.Value -> Maybe Float
parseFloat v = case v of
  Json.Number f -> Just f
  _ -> Nothing

parseInt : Json.Value -> Maybe Int
parseInt v = Maybe.map floor <| parseFloat v

toCard : Json.Value -> Maybe Card
toCard json = 
  case json of
    Json.Object c ->
      unm {
      question = p "question" parseString c,
      choices = p "chocies" parseStringArray c,
      start = Maybe.map (\x -> second * x) <| p "timeStamp" parseFloat c,
      time = p "time" parseInt c
      }
    _ -> Nothing
