module Bot.Backtest (parseHistoricData) where

import Bot.Types (BacktestTradeTick(..), BTCPrice (..), Balance (..))
import Data.Text (pack)
import Control.Monad (forM_)
import Control.Concurrent.STM (TQueue, newTQueueIO)
import Bot.BacktestEngine (backTestEngineLoop, initialBalance)
import qualified Data.Sequence as Seq
import Control.Concurrent.STM.TQueue (writeTQueue)
import Control.Monad.STM (atomically)

parseHistoricData :: IO ()
parseHistoricData = do
    btcData <- readFile "data/BTCUSDT_Binance_futures_UM_hour.csv"
    let dataLines = lines btcData
    let splitDataLines = map (wordsWhen (==',')) dataLines
    let tradeTicks = foldl (\acc line -> (BacktestTradeTick (pack (line !! 2)) (BTCPrice (read (line !! 3))) (pack (line !! 1))):acc) [] splitDataLines
    queue <- newTQueueIO :: IO (TQueue BacktestTradeTick)
    forM_ tradeTicks $ \tick -> atomically $ writeTQueue queue tick
    let initialHistory = Seq.Empty
    backTestEngineLoop initialBalance 0 queue initialHistory

wordsWhen :: (Char -> Bool) -> String -> [String]
wordsWhen p s =  case dropWhile p s of
                      "" -> []
                      s' -> w : wordsWhen p s''
                            where (w, s'') = break p s'
