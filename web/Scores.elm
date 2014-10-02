module Scores where

import Json
import Leaderboard (Player)
import Dict
import Parse
import Common (..)

unm : { name:Maybe String, score:Maybe Int} -> Maybe Player
unm {name, score} =
  name `andThen` \n ->
  score `andThen` \s ->
  Just { name=n, score=s }

toPlayer : Json.Value -> Maybe Player
toPlayer json = 
  case json of
    Json.Object c ->
      unm {
      name = Parse.p "name" Parse.string c,
      score = Parse.p "score" Parse.int c
      }
    _ -> Nothing

parse : Maybe Json.Value -> Maybe [Player]
parse v = case v of
  Just (Json.Array a) -> Just <| filterMap toPlayer a
  _ -> Nothing
