module Round where

import Json
import Parse
import Card

type Round = {
  startTime:Time,
  card:Card.Card
}

unm : { startTime:Maybe Time, card:Maybe Card.Card } -> Maybe Round
unm {startTime, card} =
  case startTime of
    Nothing -> Nothing
    Just s -> case card of
      Nothing -> Nothing
      Just c -> Just { startTime=s, card=c }

parse : Json.Value -> Maybe Round
parse json = 
  case json of
    Json.Object c ->
      unm {
        startTime = Parse.p "startTime" Parse.timestamp c,
        card = Parse.p "card" Card.parse c
      }
    _ -> Nothing