module Card where

import Json
import Parse

type Card = {
  question:String,
  choices:[String],
  time:Int
}

unm : { question:Maybe String, choices:Maybe [String], time:Maybe Int} -> Maybe Card
unm {question, choices, time} =
  case question of
    Nothing -> Nothing
    Just q -> case choices of
      Nothing -> Nothing
      Just c -> case time of
        Nothing -> Nothing
        Just t -> Just { question=q, choices=c, time=t }

parse : Json.Value -> Maybe Card
parse json = 
  case json of
    Json.Object c ->
      unm {
      question = Parse.p "question" Parse.string c,
      choices = Parse.p "choices" Parse.stringArray c,
      time = Parse.p "time" Parse.int c
      }
    _ -> Nothing
