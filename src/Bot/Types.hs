{-# LANGUAGE DeriveGeneric #-}

module Bot.Types (TradeTick(..), Balance, NumOfBTCInWallet, BTCPrice, Decision(..)) where

import GHC.Generics (Generic)
import Data.Aeson (FromJSON)
import Data.Text (Text)

data TradeTick = TradeTick
  { s :: !Text    -- Symbol (e.g., "BTCUSDT")
  , p :: !String  -- Price (Binance sends this as a string)
  } deriving (Show, Generic)

instance FromJSON TradeTick

data Decision = Buy | Sell | Hold
  deriving (Show)

type Balance = Double

type NumOfBTCInWallet = Int

type BTCPrice = Double