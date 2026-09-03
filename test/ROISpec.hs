module ROISpec (spec) where

import Bot.ROI (roiIfBuyAndHold)
import Bot.Types (Balance (Balance))
import Test.Hspec

spec :: Spec
spec = do
  describe "roiIfBuyAndHold" $ do
    it "uses the CSV close price when calculating buy-and-hold ROI" $ do
      result <- roiIfBuyAndHold (Balance 1000)
      result `shouldBe` Just 781.3437555476655
