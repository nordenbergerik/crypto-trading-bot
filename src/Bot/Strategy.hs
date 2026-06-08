module Bot.Strategy (movingAverage, makeDecision) where

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