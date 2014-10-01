module Card where

import Json
import Parse

type Card = {
  question:String,
  time:Int,
  answer:String
}

unm : { question:Maybe String, time:Maybe Int, answer:Maybe String} -> Maybe Card
unm {question, time, answer} =
  case question of
    Nothing -> Nothing
    Just q -> case time of
      Nothing -> Nothing
      Just t -> case answer of
        Nothing -> Nothing
        Just a -> Just { question=q, time=t, answer=a }

parse : Json.Value -> Maybe Card
parse json = 
  case json of
    Json.Object c ->
      unm {
      question = Parse.p "question" Parse.string c,
      time = Parse.p "time" Parse.int c,
      answer = Parse.p "answer" Parse.string c
      }
    _ -> Nothing
