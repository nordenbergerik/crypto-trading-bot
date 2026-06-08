module Bot.Engine (runBot) where

import Control.Concurrent.Async (async, wait)
import Control.Concurrent.STM (TQueue, newTQueueIO, atomically, readTQueue)

import qualified Data.Sequence as Seq
import Bot.API (streamMarketData)
import Bot.Types (Balance(Balance), TradeTick (p), NumOfBTCInWallet, BTCPrice(BTCPrice))
import Bot.Strategy (movingAverage, makeDecision)
import Data.Sequence
import Bot.Accounting (updateBalance, updateWallet, roi)

initialBalance :: Balance
initialBalance = 1000000.00000000

smaPeriod :: Int 
smaPeriod = 20

runBot :: IO ()
runBot = do
    sharedQueue <- newTQueueIO :: IO (TQueue TradeTick)
    apiThread <- async (streamMarketData sharedQueue)

    let initialHistory = Seq.Empty 
    engineLoop initialBalance 0 sharedQueue initialHistory

    wait apiThread


engineLoop :: Balance -> NumOfBTCInWallet -> TQueue TradeTick -> Seq BTCPrice -> IO ()
engineLoop balance numBTCInWallet queue history = do
    tick <- atomically $ readTQueue queue
    
    let price = BTCPrice (read (p tick)) 
    let updatedHistory = history |> price

    let trimmedHistory = if (Seq.length updatedHistory) > smaPeriod 
                        then Seq.drop 1 updatedHistory 
                        else updatedHistory

    let sma = movingAverage trimmedHistory

    let decision = makeDecision price sma balance numBTCInWallet

    let newBalance = updateBalance balance price decision

    let newNumOfBTCInWallet = updateWallet numBTCInWallet decision

    putStrLn $ "Price: " ++ show price
                ++ "\nSMA: " ++ show sma
                ++ "\n" ++ show decision 
                ++ "\nBalance: " ++ show newBalance
                ++ "\nBTC in Wallet: " ++ show newNumOfBTCInWallet
                ++ "\nROI: " ++ show (roi newBalance newNumOfBTCInWallet price initialBalance)
                ++ "\n"

    engineLoop newBalance newNumOfBTCInWallet queue trimmedHistory