module Round where

import Json
import Parse
import Card

type Round = {
  startTime:Time,
  card:Card.Card,
  choices:[String]
}

unm : { startTime:Maybe Time, card:Maybe Card.Card, choices:Maybe [String] } -> Maybe Round
unm {startTime, card, choices} =
  case startTime of
    Nothing -> Nothing
    Just s -> case card of
      Nothing -> Nothing
      Just c -> case choices of
        Nothing -> Nothing
        Just ch -> Just { startTime=s, card=c, choices=ch }

parse : Json.Value -> Maybe Round
parse json = 
  case json of
    Json.Object c ->
      unm {
        startTime = Parse.p "startTime" Parse.timestamp c,
        card = Parse.p "card" Card.parse c,
        choices = Parse.p "choices" Parse.stringArray c
      }
    _ -> Nothing