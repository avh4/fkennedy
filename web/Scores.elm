module Scores where

import Json
import Leaderboard (Player)
import Dict

y : (String, Int) -> Player
y (name, score) = {name=name,score=score}

x : Dict.Dict String Int -> [Player]
x d = map y <| Dict.toList d

pi : (String, Json.Value) -> Maybe (String, Int)
pi (key, v) = case v of
  Json.Number n -> Just (key, floor n)
  _ -> Nothing

toIntDict : Dict.Dict String Json.Value -> Dict.Dict String Int
toIntDict d = Dict.fromList <| filterMap pi (Dict.toList d)

parse : Maybe Json.Value -> Maybe [Player]
parse v = case v of
  Just (Json.Object d) -> Just (x <| toIntDict d)
  _ -> Nothing
