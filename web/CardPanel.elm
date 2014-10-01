module CardPanel where

import Round
import Round (Round)
import Text
import String
import Debug

colorBg1 t = hsl (degrees 200 + t*0.0003) 0.4 0.5
colorBg2 t = hsl (degrees 200 + t*0.00002) 0.4 0.8

background : (Int,Int) -> Time -> Element
background (w,h) now = collage (w) h
  [ gradient (linear
    (toFloat w * sin (now*0.0001),0)
    (toFloat w * sin (now*0.00007),toFloat h)
    [(0,colorBg1 now), (1, colorBg2 now)])
    (rect (toFloat w) (toFloat h))]

timerText : String -> Element
timerText s = leftAligned <| Text.style { typeface = [ ]
  , height   = Just 64
  , color    = black
  , bold     = True
  , italic   = False
  , line     = Nothing
  } <| toText s

choiceText : String -> Element
choiceText s = leftAligned <| Text.style { typeface = [ ]
  , height   = Just 32
  , color    = black
  , bold     = True
  , italic   = False
  , line     = Nothing
  } <| toText s

titleText : String -> Element
titleText s = leftAligned <| Text.style { typeface = [ ]
  , height   = Just 32
  , color    = black
  , bold     = False
  , italic   = False
  , line     = Nothing
  } <| toText s

fmtTimer : Int -> String
fmtTimer t = "0:" ++ (String.padLeft 2 '0' <| show <| floor <| inSeconds <| toFloat t)

data TimerState =
  Before Int | Running Int | Done

toTimer : Time -> Int -> Time -> TimerState
toTimer startTime time now = 
  let left = floor <| startTime - now + (millisecond * toFloat time)
  in if | left > time -> Before time
        | left >= 0   -> Running left
        | otherwise   -> Done

timerView : Round.Round -> Time -> Element
timerView round now = 
  case toTimer round.startTime round.card.time now of
    Before t -> timerText <| "(" ++ (fmtTimer round.card.time) ++ ")"
    Running t -> timerText <| fmtTimer t
    Done -> timerText "Time's up"

choiceColor : String -> Bool -> String -> Color
choiceColor answer b s = 
  let match = b && answer == s
  in (hsl (degrees 100) (if match then 0.9 else 0.2) (if match then 0.5 else 0.9))

choice : String -> Bool -> String -> Element
choice answer b s = container 160 60 middle <| color (choiceColor answer b s) <| container 140 40 middle <| choiceText s

isOver : Round -> Time -> Bool
isOver r now = case toTimer r.startTime r.card.time now of
  Done -> True
  _ -> False

view (w,h) round now = layers [
    background (w,h) now,
    case round of
      Just round -> 
        flow down [
        container w 70 midBottom <| titleText "Name that dude!",
        container w 110 middle <| timerView round now,
        container w 300 middle <| fittedImage 300 300 round.card.question,
        container w 40 midBottom <| plainText "Text to 858-365-0360, or use the mobile app to play",
        container w 100 middle <| flow right <| map (choice round.card.answer (isOver round now)) round.card.choices
        ]
      Nothing -> container w 300 middle <| timerText "Waiting for next round..."
    ]
