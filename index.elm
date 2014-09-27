import Html
import Html (..)
import Window
import Json
import Dict
import Http

server = "http://localhost:4008"
colorBg1 = hsl (degrees 200) 0.5 0.5
colorBg2 = rgb 0 1 0

main = scene <~ Window.dimensions ~ (toCard <~ json) ~ (every second)

scene : (Int,Int) -> Maybe Card -> Time -> Element
scene dim card now = case card of
  Just card -> cardScene dim card now
  Nothing -> asText "No card"

cardScene : (Int, Int) -> Card -> Time -> Element
cardScene (w,h) card now =
  collage w h [
    gradient (linear (0,0) (-100,toFloat h) [(0,colorBg1), (1, colorBg2)]) (rect (toFloat w) (toFloat h)),
    toForm <| fittedImage 300 300 card.question,
    moveY -200 <| toForm <| plainText <| join "\n" card.choices,
    moveY 200 <| toForm <| plainText <| show <| floor <| inSeconds (card.start - now + (toFloat card.time))
    ]

type Card = {
  question:String,
  choices:[String],
  start:Time,
  time:Int
}

parseCardImage : (Dict.Dict String Json.Value) -> String
parseCardImage d =
  let v = Dict.getOrElse (Json.String "BAD") "question" d
  in case v of
    Json.String s -> s
    _ -> "BAD"

parseString : Json.Value -> String
parseString v = case v of
  Json.String s -> s
  _ -> "STRANGE JSON"

parseCardChoices : (Dict.Dict String Json.Value) -> [String]
parseCardChoices d =
  let v = Dict.getOrElse (Json.Array []) "choices" d
  in case v of
    Json.Array a -> map parseString a
    _ -> []

toCard : Json.Value -> Maybe Card
toCard json = 
  case json of
    Json.Object c ->
      Just {
      question = parseCardImage c,
      choices = parseCardChoices c,
      start = 1411859740 * second,
      time = 10
      }
    _ -> Nothing

parseJson : Http.Response String -> Json.Value
parseJson r = case r of
  Http.Success s -> case Json.fromString s of
    Just v -> v
    Nothing -> Json.Null
  _ -> Json.Null

json : Signal Json.Value
json = parseJson <~ Http.sendGet (constant (server ++ "/api/v1/testCards"))
