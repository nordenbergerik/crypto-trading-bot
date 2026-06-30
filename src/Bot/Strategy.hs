module Bot.Strategy (movingAverage, makeDecision, movingAverageCrossoverStrategy) where

import Bot.Types (NumOfBTCInWallet, Decision(..), BTCPrice (BTCPrice), Balance(Balance))
import Data.Sequence (Seq)
import qualified Data.Sequence as Seq

movingAverage :: Seq BTCPrice -> BTCPrice
movingAverage priceList = (sum priceList) / (fromIntegral $ Seq.length priceList) 

makeDecision :: BTCPrice -> BTCPrice -> Balance -> NumOfBTCInWallet -> Decision
makeDecision (BTCPrice price) (BTCPrice sma) (Balance balance) btcInWallet 
    | price > sma && balance >= price = Buy
    | price < sma && btcInWallet > 0  = Sell
    | otherwise                       = Hold

slidingMovingAverage :: Int -> Seq BTCPrice -> Seq BTCPrice
slidingMovingAverage windowSize priceList
    | Seq.length priceList < windowSize = Seq.empty
    | otherwise = let (window, _) = Seq.splitAt windowSize priceList
                      avg = movingAverage window
                  in avg Seq.<| slidingMovingAverage windowSize (Seq.drop 1 priceList)

--Moving average crossover strategy: Buy when price crosses above the moving average, sell when it crosses below.
movingAverageCrossoverStrategy :: Seq BTCPrice -> Seq BTCPrice -> Seq Decision
movingAverageCrossoverStrategy shortSMA longSMA = Seq.zipWith3 decideSignal shortSMA longSMA (Seq.drop 1 shortSMA)
    where
        decideSignal smaShort smaLong nextSmaShort 
            | smaShort > smaLong && nextSmaShort <= smaLong = Sell
            | smaShort < smaLong && nextSmaShort >= smaLong = Buy
            | otherwise = Hold