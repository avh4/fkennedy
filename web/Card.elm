module Card where

import Json
import Parse

type Card = {
  question:String,
  answer:String
}

unm : { question:Maybe String, answer:Maybe String} -> Maybe Card
unm {question, answer} =
  case question of
    Nothing -> Nothing
    Just q -> case answer of
      Nothing -> Nothing
      Just a -> Just { question=q, answer=a }

parse : Json.Value -> Maybe Card
parse json = 
  case json of
    Json.Object c ->
      unm {
      question = Parse.p "question" Parse.string c,
      answer = Parse.p "answer" Parse.string c
      }
    _ -> Nothing
