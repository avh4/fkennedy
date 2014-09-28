module Leaderboard where

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
cmix x = mix color1 color2 x

leaderboard : (Int,Int) -> [Player] -> Element
leaderboard (w,h) p = color color2 <| container w h topLeft <| flow down [
  plainText "Leaderboard",
  color (cmix 0.80) <| container w 50 middle <| plainText <| "Aaron: 80%",
  color (cmix 0.72) <| container w 50 middle <| plainText <| "Drew: 72%",
  color (cmix 0.63) <| container w 50 middle <| plainText <| "Babs: 63%",
  color (cmix 0.18) <| container w 50 middle <| plainText <| "Rudolpho: 18%"
  ]
