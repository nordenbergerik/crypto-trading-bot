module ROISpec (spec) where

import Test.Hspec
import Bot.ROI (roiIfBuyAndHold)
import Bot.Types (Balance (Balance))

spec :: Spec
spec = do
  describe "roiIfBuyAndHold" $ do
    it "uses the CSV close price when calculating buy-and-hold ROI" $ do
      result <- roiIfBuyAndHold (Balance 1000)
      result `shouldBe` Just (-886.5368939525076)
