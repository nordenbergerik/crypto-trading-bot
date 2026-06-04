{-# LANGUAGE OverloadedStrings #-}

module Bot.API (streamMarketData) where

import Control.Concurrent.STM (TQueue, atomically, writeTQueue)
import Control.Monad (forever)
import Data.Aeson (decodeStrict)
import Network.WebSockets (receiveData)
import Wuss (runSecureClient)
import Bot.Types (TradeTick)

streamMarketData :: TQueue TradeTick -> IO ()
streamMarketData queue = do 
    let host = "stream.binance.com"
        port = 9443
        path = "/ws/btcusdt@trade"

    putStrLn "Connecting to Binance..."
    runSecureClient host port path $ \connection -> do
        putStrLn "Connected!"
        forever $ do
            rawData <- receiveData connection
            case decodeStrict rawData of 
                Just tick -> atomically $ writeTQueue queue tick
                Nothing -> return ()
