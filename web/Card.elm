module Card where

import Json
import Parse
import Common (..)

type Card = {
  question:String,
  answer:String
}

unm : { question:Maybe String, answer:Maybe String} -> Maybe Card
unm {question, answer} =
  question `andThen` \q ->
  answer `andThen` \a ->
  Just { question=q, answer=a}

parse : Json.Value -> Maybe Card
parse json = 
  case json of
    Json.Object c ->
      unm {
      question = Parse.p "question" Parse.string c,
      answer = Parse.p "answer" Parse.string c
      }
    _ -> Nothing
