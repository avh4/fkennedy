module Message where

import Json
import Dict
import Round (Round)
import Round

type Summary = {
  winners:[String],
  answer:String
}

data Message =
  Next Round |
  Summary_ Summary |
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
  Just (Json.String "summary") -> Summary_ {winners=[],answer="XXX"}
  Just _ -> Unrecognized "Unknown type"
  _ -> Unrecognized "No type"
