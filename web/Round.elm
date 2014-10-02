module Round where

import Json
import Parse
import Card
import Common (..)

type Round = {
  startTime:Time,
  card:Card.Card,
  choices:[String],
  time:Int
}

unm : { startTime:Maybe Time, card:Maybe Card.Card, choices:Maybe [String], time:Maybe Int } -> Maybe Round
unm {startTime, card, choices, time} =
  startTime `andThen` \s ->
  card `andThen` \c ->
  choices `andThen` \ch ->
  time `andThen` \t ->
  Just { startTime=s, card=c, choices=ch, time=t }

parse : Json.Value -> Maybe Round
parse json = 
  case json of
    Json.Object c ->
      unm {
        startTime = Parse.p "startTime" Parse.timestamp c,
        card = Parse.p "card" Card.parse c,
        choices = Parse.p "choices" Parse.stringArray c,
        time = Parse.p "time" Parse.int c
      }
    _ -> Nothing