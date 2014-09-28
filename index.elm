import Html
import Html (..)
import Window
import Json
import Http

import Card
import Round
import Leaderboard (leaderboard)

server = "http://localhost:4008"
colorBg1 = hsl (degrees 200) 0.5 0.5
colorBg2 = rgb 0 1 0

main = scene <~ Window.dimensions ~ (Round.parse <~ json) ~ (every (second * 0.5))

scene : (Int,Int) -> Maybe Round.Round -> Time -> Element
scene dim card now = case card of
  Just card -> cardScene dim card now
  Nothing -> asText "No card"

timerView : Round.Round -> Time -> Element
timerView round now = 
  let left = floor <| round.startTime - now + (millisecond * toFloat round.card.time)
  in if | left > round.card.time -> plainText <| "(" ++ (show <| inSeconds <| toFloat round.card.time) ++ ")"
        | left >= 0        -> plainText <| show <| floor <| inSeconds <| toFloat <| left
        | otherwise        -> plainText "!!!"

cardScene : (Int, Int) -> Round.Round -> Time -> Element
cardScene (w,h) round now =
  collage w h [
    gradient (linear (0,0) (-100,toFloat h) [(0,colorBg1), (1, colorBg2)]) (rect (toFloat w) (toFloat h)),
    moveX -300 <| toForm <| leaderboard (100, 100) [],
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
