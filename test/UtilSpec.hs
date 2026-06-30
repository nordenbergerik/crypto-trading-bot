module UtilSpec (spec) where

import Test.Hspec

spec :: Spec
spec = do
  describe "placeholder" $ do
    it "keeps the test suite compiling" $ do
      True `shouldBe` True
