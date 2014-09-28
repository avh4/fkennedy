import Html
import Html (..)
import Window
import Json
import Http

import Card
import Leaderboard (leaderboard)

server = "http://localhost:4008"
colorBg1 = hsl (degrees 200) 0.5 0.5
colorBg2 = rgb 0 1 0

main = scene <~ Window.dimensions ~ (Card.toCard <~ json) ~ (every (second * 0.5))

scene : (Int,Int) -> Maybe Card.Card -> Time -> Element
scene dim card now = case card of
  Just card -> cardScene dim card now
  Nothing -> asText "No card"

timerView : Card.Card -> Time -> Element
timerView card now = 
  let left = floor <| inSeconds (card.start - now + (second * toFloat card.time))
  in if | left > card.time -> plainText <| "(" ++ (show card.time) ++ ")"
        | left >= 0        -> plainText <| show left
        | otherwise        -> plainText "!!!"

cardScene : (Int, Int) -> Card.Card -> Time -> Element
cardScene (w,h) card now =
  collage w h [
    gradient (linear (0,0) (-100,toFloat h) [(0,colorBg1), (1, colorBg2)]) (rect (toFloat w) (toFloat h)),
    moveX -300 <| toForm <| leaderboard (100, 100) [],
    toForm <| fittedImage 300 300 card.question,
    moveY -200 <| toForm <| plainText <| join "\n" card.choices,
    moveY 200 <| toForm <| timerView card now
    ]

parseJson : Http.Response String -> Json.Value
parseJson r = case r of
  Http.Success s -> case Json.fromString s of
    Just v -> v
    Nothing -> Json.Null
  _ -> Json.Null

json : Signal Json.Value
json = parseJson <~ Http.sendGet (constant (server ++ "/api/v1/testCards"))
