module Common where

andThen : Maybe a -> (a -> Maybe b) -> Maybe b
andThen ma fn = case ma of
  Just a -> fn a
  Nothing -> Nothing
