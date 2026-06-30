module Bot.Backtest (parseAndSimulateHistoricData) where

import Bot.Types (BacktestTradeTick(..), BTCPrice (..), Balance (..))
import Data.Text (pack)
import Control.Monad (forM_)
import Control.Concurrent.STM (TQueue, newTQueueIO)
import Bot.BacktestEngine (backTestEngineLoop, initialBalance)
import qualified Data.Sequence as Seq
import Control.Concurrent.STM.TQueue (writeTQueue)
import Control.Monad.STM (atomically)
import Bot.ROI(tryReadFile)
import Data.Maybe

parseAndSimulateHistoricData :: IO ()
parseAndSimulateHistoricData = do
    btcDataResult <- tryReadFile "data/BTCUSDT_Binance_futures_UM_hour.csv"
    case btcDataResult of
        Left e -> do
            putStrLn $ "Error reading BTC data: " ++ show e
        Right btcData -> do
            let dataLines = reverse $ drop 2 $ filter (not . null) (lines btcData)
            let tradeTicks = catMaybes $ map parseTradeTick dataLines
            queue <- newTQueueIO :: IO (TQueue BacktestTradeTick)
            forM_ tradeTicks $ \tick -> atomically $ writeTQueue queue tick
            let initialHistory = Seq.Empty
            backTestEngineLoop initialBalance 0 queue initialHistory (BTCPrice 0.0)

wordsWhen :: (Char -> Bool) -> String -> [String]
wordsWhen p s =  case dropWhile p s of
                      "" -> []
                      s' -> w : wordsWhen p s''
                            where (w, s'') = break p s'

parseTradeTick :: String -> Maybe BacktestTradeTick
parseTradeTick line =
    let parts = wordsWhen (==',') line
    in if length parts >= 4
       then Just $ BacktestTradeTick (pack (parts !! 2)) (BTCPrice (read (parts !! 3))) (pack (parts !! 1))
       else Nothing