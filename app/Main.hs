module Main (main) where

import qualified Bot
import qualified Bot.Backtest

main :: IO ()
main = do
    putStrLn "Live trading or backtesting? (l/b)"
    choice <- getLine
    case choice of
        "l" -> Bot.startApp
        "b" -> Bot.Backtest.parseAndSimulateHistoricData
        _ -> putStrLn "Invalid choice. Please enter 'l' for live trading or 'b' for backtesting."
    