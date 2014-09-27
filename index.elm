import Html
import Html (..)
import Window
import Json

main = scene <~ Window.dimensions ~ json

scene (w,h) json =
    Html.toElement w h (game json)

game : Json.Value -> Html
game json =
    node "div" [ "className" := "profile" ] []
      [ node "img" [ "src" := card.question ] [] []
      , node "div" [] [] 
        (map (\x -> text x) card.choices)
      ]

type Card = {
  question:String,
  choices:[String]
}

card : Card
card = {
  question="http://placekitten.com/g/200/200",
  choices=["Samn", "Jenn", "Alen", "Tomn"]
  }
--card : Json.Value -> Card
--card = Card { question:"http://placekitten.com/g/200/200", choices:}

json : Signal Json.Value
json = constant (Json.String "aa")
--json = constantly <| Json.Object (Dict.fromList [(
--  "question" "http://placekitten.com/g/200/200"
--  "choices" (Json.Array ["Samn" "Jenn" "Alen" "Tomn"])
--)])