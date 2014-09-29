module Message where

import Json
import Dict
import Round (Round)
import Round
import Leaderboard (Player)
import Scores
import Debug

type Summary = {
  winners:[String],
  answer:String
}

data Message =
  Next Round |
  NewSummary Summary |
  Scores [Player] |
  Unrecognized String

parse : String -> Message
parse s = case Json.fromString s of
  Just (Json.Object d) -> parseDict d
  Just _ -> Unrecognized "Not an object"
  Nothing -> Unrecognized "JSON didn't parse"

parseDict : Dict.Dict String Json.Value -> Message
parseDict d = case Dict.get "type" d of
  Just (Json.String "next") -> case Dict.get "message" d of
    Just v -> case Round.parse v of
      Just r -> Next r
      Nothing -> Unrecognized "Round failed to parse"
    Nothing -> Unrecognized "No message"
  Just (Json.String "summary") -> NewSummary {winners=[],answer="XXX"}
  Just (Json.String "scores") -> case Scores.parse <| Dict.get "message" d of
    Just s -> Scores s
    Nothing -> Unrecognized "Scores failed to parse"
  Just _ -> Unrecognized "Unknown type"
  _ -> Unrecognized "No type"
