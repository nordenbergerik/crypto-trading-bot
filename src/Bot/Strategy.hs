module Bot.Strategy (movingAverage, makeDecision) where

import Data.Sequence (Seq)
import Bot.Types (NumOfBTCInWallet, Decision(..))


movingAverage :: Seq Double -> Double
movingAverage priseList = (sum priseList) / (fromIntegral $ length priseList) 

makeDecision :: Double -> Double -> Double -> NumOfBTCInWallet -> Decision
makeDecision marketPrice sma balance btcInWallet =
    case () of _
                | marketPrice > sma && balance - marketPrice > 0 -> Buy
                | marketPrice < sma && btcInWallet > 0           -> Sell
                | otherwise                                      -> Hold