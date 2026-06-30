module Bot.BacktestEngine where

import Bot.Types (BacktestTradeTick (..), Balance (Balance), NumOfBTCInWallet, BTCPrice(..))
import Control.Concurrent.STM
import qualified Data.Sequence as Seq
import Data.Sequence (Seq)
import Bot.Strategy (movingAverage, makeDecision)
import Bot.Accounting (updateBalance, updateWallet, roi)
import Bot.ROI (roiIfBuyAndHold)
import Control.Monad.STM (atomically)

initialBalance :: Balance
initialBalance = 1000000.00000000

smaPeriod :: Int 
smaPeriod = 20

runBacktest :: IO ()
runBacktest = do
    queue <- newTQueueIO :: IO (TQueue BacktestTradeTick)
    let initialHistory = Seq.Empty 
    backTestEngineLoop initialBalance 0 queue initialHistory 0.0

backTestEngineLoop :: Balance -> NumOfBTCInWallet -> TQueue BacktestTradeTick -> Seq BTCPrice -> BTCPrice -> IO ()
backTestEngineLoop balance numBTCInWallet queue history lastPrice = do
    tickResult <- atomically $ tryReadTQueue queue
    
    case tickResult of
        Nothing -> do
            -- Queue is empty, simulation finished
            putStrLn "\n=== Simulation Complete ==="
            roiResult <- roiIfBuyAndHold initialBalance
            case roiResult of
                Just roi' -> putStrLn $ "ROI if Buy and Hold: " ++ show roi'
                            ++ "\nTradingbot ROI: " ++ show (roi balance numBTCInWallet lastPrice initialBalance)
                Nothing -> putStrLn "Could not calculate buy and hold ROI"             

        Just tick -> do
            let price = btPrice tick
            let updatedHistory = history Seq.|> price

            let trimmedHistory = if (Seq.length updatedHistory) > smaPeriod 
                                then Seq.drop 1 updatedHistory 
                                else updatedHistory

            let sma = movingAverage trimmedHistory

            let decision = makeDecision price sma balance numBTCInWallet

            let newBalance = updateBalance balance price decision

            let newNumOfBTCInWallet = updateWallet numBTCInWallet decision
            -- putStrLn "bajskorv"
            -- putStrLn $ "Price: " ++ show price ++ ", SMA: " ++ show sma ++ ", Decision: " ++ show decision ++ ", Balance: " ++ show newBalance ++ ", BTC in Wallet: " ++ show newNumOfBTCInWallet
            backTestEngineLoop newBalance newNumOfBTCInWallet queue trimmedHistory price