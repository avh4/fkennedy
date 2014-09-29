import Html
import Html (..)
import Window
import Json
import Http
import Dict
import Debug
import WebSocket
import Maybe

import Parse
import Card
import Round
import Round (Round)
import Leaderboard (leaderboard, Player)
import CardPanel
import Message
import Message (Message)

server = "http://fkennedy.herokuapp.com"

main = scene <~ Window.dimensions ~ round ~ (every (second * 0.05)) ~ players

scene : (Int,Int) -> Maybe Round.Round -> Time -> Maybe [Player] -> Element
scene dim card now players = cardScene dim card now players

cardScene : (Int, Int) -> Maybe Round.Round -> Time -> Maybe [Player] -> Element
cardScene (w,h) round now players =
  leaderboard (300, h) players
  `beside`
  CardPanel.view (w-300,h) round now

ws = WebSocket.connect "ws://fkennedy.herokuapp.com/api/v1/stream" (constant "")

wsd = (\m -> Debug.log "ws" <| Message.parse m) <~ ws

r : Message -> Maybe Round
r m = case m of
  Message.Next r -> Just r
  _ -> Nothing

round : Signal (Maybe Round)
round = keepIf Maybe.isJust Nothing (r <~ wsd)
--round = (Round.parse <~ (parseJson <~ Http.sendGet (constant (server ++ "/api/v1/testCards"))))

parseJson : Http.Response String -> Json.Value
parseJson r = case r of
  Http.Success s -> case Json.fromString s of
    Just v -> v
    Nothing -> Json.Null
  _ -> Json.Null

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

parsePlayers : Maybe Json.Value -> Maybe [Player]
parsePlayers v = case v of
  Just (Json.Object d) -> Just (x <| toIntDict d)
  _ -> Nothing

pj : Http.Response String -> Maybe Json.Value
pj r = case r of
  Http.Success s -> Json.fromString s
  _ -> Nothing

players : Signal (Maybe [Player])
players = parsePlayers <~ (pj <~ Http.sendGet (constant (server ++ "/api/v1/scores")))
