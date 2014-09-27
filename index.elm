import Html
import Html (..)
import Window
import Json
import Dict
import Http

server = "http://localhost:4008"

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

parseJson : Http.Response String -> Json.Value
parseJson r = case r of
  Http.Success s -> case Json.fromString s of
    Just v -> v
    Nothing -> Json.Null
  _ -> Json.Null

json : Signal Json.Value
json = parseJson <~ Http.sendGet (constant (server ++ "/api/v1/testCards"))
