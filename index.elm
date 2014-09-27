import Html
import Html (..)
import Window
import Json
import Dict

main = scene <~ Window.dimensions ~ (toCard <~ json)

scene (w,h) card =
    Html.toElement w h (game card)

game : Maybe Card -> Html
game mcard =
  case mcard of
  Just card -> 
    node "div" [ "className" := "profile" ] []
      [ node "img" [ "src" := card.question ] [] []
      , node "div" [] []
        (map (\x -> text x) card.choices)
      ]
  Nothing -> node "div" [] [] [ text "No card" ]

type Card = {
  question:String,
  choices:[String]
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
      choices= parseCardChoices c
      }
    _ -> Nothing

json : Signal Json.Value
json = constant (Json.Object (Dict.fromList [
  ("question", Json.String "http://placekitten.com/g/400/160"),
  ("choices", Json.Array (map Json.String ["Aaron", "Drew", "Alex", "Jessica"]))
  ]))
