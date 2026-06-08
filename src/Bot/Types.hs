{-# LANGUAGE DeriveGeneric #-}
-- {-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Bot.Types (TradeTick(..), Balance(..), NumOfBTCInWallet, BTCPrice(..), Decision(..)) where

import GHC.Generics (Generic)
import Data.Aeson (FromJSON)
import Data.Text (Text)
import Data.Fixed (Fixed, HasResolution(resolution))

data E8 = E8
instance HasResolution E8 where
  resolution _ = 100000000

type CryptoFixed = Fixed E8

newtype Balance = Balance CryptoFixed
  deriving (Show, Eq, Ord, Num, Real, Fractional)

newtype BTCPrice = BTCPrice CryptoFixed
  deriving (Show, Read, Eq, Ord, Num, Real, Fractional)

type NumOfBTCInWallet = Int

data TradeTick = TradeTick
  { s :: !Text    -- Symbol (e.g., "BTCUSDT")
  , p :: !String  -- Price (Binance sends this as a string)
  } deriving (Show, Generic)

instance FromJSON TradeTick

data Decision = Buy | Sell | Hold
  deriving (Show)

