module Card where

import Json
import Parse

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

toCard : Json.Value -> Maybe Card
toCard json = 
  case json of
    Json.Object c ->
      unm {
      question = Parse.p "question" Parse.string c,
      choices = Parse.p "chocies" Parse.stringArray c,
      start =  Parse.p "timeStamp" Parse.timestamp c,
      time = Parse.p "time" Parse.int c
      }
    _ -> Nothing
