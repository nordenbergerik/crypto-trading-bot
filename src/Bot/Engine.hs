module Bot.Engine (runBot) where

import Control.Concurrent.Async (async, wait)
import Control.Concurrent.STM (TQueue, newTQueueIO, atomically, readTQueue)
import Control.Monad (forever)
import Bot.API (streamMarketData)
import Bot.Types (TradeTick)

runBot :: IO ()
runBot = do
    sharedQueue <- newTQueueIO :: IO (TQueue TradeTick)
    apiThread <- async (streamMarketData sharedQueue)

    forever $ do
        tick <- atomically $ readTQueue sharedQueue
        putStrLn $ "Engine recieved: " ++ show tick

    wait apiThread