module Main where

import Test.Hspec
import qualified ROISpec
import qualified UtilSpec

main :: IO ()
main = hspec $ do
  ROISpec.spec
  UtilSpec.spec
