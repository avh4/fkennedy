import Html
import Html (..)
import Window
import Json
import Http
import Dict
import Debug

import Parse
import Card
import Round
import Leaderboard (leaderboard, Player)

server = "http://localhost:4008"
colorBg1 = hsl (degrees 200) 0.5 0.5
colorBg2 = rgb 0 1 0

main = scene <~ Window.dimensions ~ (Round.parse <~ json) ~ (every (second * 0.5)) ~ players

scene : (Int,Int) -> Maybe Round.Round -> Time -> Maybe [Player] -> Element
scene dim card now players = case card of
  Just card -> cardScene dim card now players
  Nothing -> asText "No card"

timerView : Round.Round -> Time -> Element
timerView round now = 
  let left = floor <| round.startTime - now + (millisecond * toFloat round.card.time)
  in if | left > round.card.time -> plainText <| "(" ++ (show <| inSeconds <| toFloat round.card.time) ++ ")"
        | left >= 0        -> plainText <| show <| floor <| inSeconds <| toFloat <| left
        | otherwise        -> plainText "!!!"

cardScene : (Int, Int) -> Round.Round -> Time -> Maybe [Player] -> Element
cardScene (w,h) round now players =
  (leaderboard (300, h) players)
  `beside`
  collage (w-300) h [
    gradient (linear (0,0) (-100,toFloat h) [(0,colorBg1), (1, colorBg2)]) (rect (toFloat w) (toFloat h)),
    toForm <| fittedImage 300 300 round.card.question,
    moveY -200 <| toForm <| plainText <| join "\n" round.card.choices,
    moveY 200 <| toForm <| timerView round now
    ]

parseJson : Http.Response String -> Json.Value
parseJson r = case r of
  Http.Success s -> case Json.fromString s of
    Just v -> v
    Nothing -> Json.Null
  _ -> Json.Null

json : Signal Json.Value
json = parseJson <~ Http.sendGet (constant (server ++ "/api/v1/testCards"))

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

players : Signal (Maybe [Player])
players = constant <| parsePlayers <| Json.fromString "{\"Aaron\":80,\"Drew\":72}"
