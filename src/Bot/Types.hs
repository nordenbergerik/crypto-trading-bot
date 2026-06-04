{-# LANGUAGE DeriveGeneric #-}

module Bot.Types where

import GHC.Generics (Generic)
import Data.Aeson (FromJSON)
import Data.Text (Text)

data TradeTick = TradeTick
  { s :: !Text    -- Symbol (e.g., "BTCUSDT")
  , p :: !String  -- Price (Binance sends this as a string)
  } deriving (Show, Generic)

instance FromJSON TradeTick