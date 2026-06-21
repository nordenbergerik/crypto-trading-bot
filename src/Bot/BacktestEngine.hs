module Bot.BacktestEngine where

import Bot.Types (BacktestTradeTick (..), Balance, NumOfBTCInWallet, BTCPrice(..))
import Control.Concurrent.STM
import qualified Data.Sequence as Seq
import Data.Sequence (Seq)
import Bot.Strategy (movingAverage, makeDecision)
import Bot.Accounting (updateBalance, updateWallet, roi)
import Bot.ROI (roiIfBuyAndHold)
import Control.Exception (try, IOException)

initialBalance :: Balance
initialBalance = 1000000.00000000

smaPeriod :: Int 
smaPeriod = 20

runBacktest :: IO ()
runBacktest = do
    queue <- newTQueueIO :: IO (TQueue BacktestTradeTick)

    let initialHistory = Seq.Empty 
    backTestEngineLoop initialBalance 0 queue initialHistory

backTestEngineLoop :: Balance -> NumOfBTCInWallet -> TQueue BacktestTradeTick -> Seq BTCPrice -> IO ()
backTestEngineLoop balance numBTCInWallet queue history = do
    tickResult <- try (atomically $ readTQueue queue) :: IO (Either IOException BacktestTradeTick)
    
    case tickResult of
        Left _ -> do
            -- Queue is empty, simulation finished
            putStrLn "\n=== Simulation Complete ==="
            roiResult <- roiIfBuyAndHold balance
            case roiResult of
                Just roi -> putStrLn $ "ROI if Buy and Hold: " ++ show roi
                Nothing -> putStrLn "Could not calculate buy and hold ROI"
        Right tick -> do
            let price = btPrice tick
            let updatedHistory = history Seq.|> price

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
                        ++ "\nDate: " ++ show (btDate tick)
                        ++ "\n"

            backTestEngineLoop newBalance newNumOfBTCInWallet queue trimmedHistory