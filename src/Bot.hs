module Bot (startApp) where

import qualified Bot.Engine as Engine

startApp :: IO ()
startApp = Engine.runBot