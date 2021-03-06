module Leaderboard where

import Text

type Player = {
  name:String,
  score:Int
}

color1 = (hsl (degrees 0) 0.75 0.5)
color2 = (hsl (degrees 0) 0 0.9)

avg : Int -> Int -> Int
avg a b = (a + b) // 2

mix : Color -> Color -> Float -> Color
mix a_ b_ x1 = 
  let c1 = toRgb a_
      c2 = toRgb b_
      x2 = 1 - x1
      r = floor ((toFloat c1.red * x1) + (toFloat c2.red * x2))
      g = floor ((toFloat c1.green * x1) + (toFloat c2.green * x2))
      b = floor ((toFloat c1.blue * x1) + (toFloat c2.blue * x2))
  in rgba r g b 1

cmix : Float -> Color
cmix x = mix color1 color2 (clamp 0 1 x)

playerText : String -> Element
playerText s = leftAligned <| Text.style { typeface = [ ]
  , height   = Just 24
  , color    = (hsl 0 0 0.3)
  , bold     = False
  , italic   = False
  , line     = Nothing
  } <| toText s

scoreText : String -> Element
scoreText s = leftAligned <| Text.style { typeface = [ ]
  , height   = Just 24
  , color    = (hsl 0 0 0.0)
  , bold     = True
  , italic   = False
  , line     = Nothing
  } <| toText s

showPlayer : Int -> Player -> Element
showPlayer w p = color (cmix <| toFloat p.score / 100) <| 
  layers [
    container w 50 midLeft <| (spacer 15 10) `beside` playerText p.name,
    container w 50 midRight <| (scoreText <| (show p.score) ++ "%") `beside` (spacer 15 10)
    ]

leaderboard : (Int,Int) -> Maybe [Player] -> Element
leaderboard (w,h) mps = case mps of
  Just ps ->
    color color2 <| container w h topLeft <| flow down <| [
    container w 50 middle <| playerText "Leaderboard"]
    ++ map (showPlayer w) (sortBy (\p -> -p.score) ps)
  Nothing -> color color2 <| container w h topLeft <| flow down <| [
    container w 50 middle <| playerText "Leaderboard",
    plainText "..."]

