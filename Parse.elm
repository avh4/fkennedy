module Parse where

import Dict
import Json
import Maybe

p : String -> (Json.Value -> Maybe a) -> (Dict.Dict String Json.Value) -> Maybe a
p key fn d = case (Dict.get key d) of
  Just v -> fn v
  Nothing -> Nothing

string : Json.Value -> Maybe String
string v = case v of
  Json.String s -> Just s
  _ -> Nothing

stringArray : Json.Value -> Maybe [String]
stringArray v = case v of
  Json.Array a -> Just <| filterMap identity <| map string a
  _ -> Nothing

float : Json.Value -> Maybe Float
float v = case v of
  Json.Number f -> Just f
  _ -> Nothing

int : Json.Value -> Maybe Int
int v = Maybe.map floor <| float v

timestamp : Json.Value -> Maybe Time
timestamp v = Maybe.map (\x -> millisecond * x) <| float v

object : (Dict.Dict String Json.Value -> c) -> Json.Value -> Maybe c
object fn v = case v of
  Json.Object d -> Just <| fn d
  _ -> Nothing
