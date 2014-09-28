module Leaderboard where

type Player = {
  name:String,
  score:Int
}

leaderboard : (Int,Int) -> [Player] -> Element
leaderboard (w,h) p = flow down [
  plainText <| "Aaron" ++ ": " ++ (show 7)
  ]
