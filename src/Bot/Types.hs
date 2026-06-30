{-# LANGUAGE DeriveGeneric #-}
-- {-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Bot.Types (TradeTick(..), BacktestTradeTick(..), Balance(..), NumOfBTCInWallet, BTCPrice(..), Decision(..), BTCHistoricDayData) where

import GHC.Generics (Generic)
import Data.Aeson (FromJSON)
import Data.Text (Text)
import Data.Fixed (Fixed, HasResolution(resolution))

data E8 = E8
instance HasResolution E8 where
  resolution _ = 100000000

type CryptoFixed = Fixed E8

newtype Balance = Balance CryptoFixed
  deriving (Show, Eq, Ord, Num, Real, Fractional, Read)

newtype BTCPrice = BTCPrice CryptoFixed
  deriving (Show, Eq, Ord, Num, Real, Fractional, Read)

type NumOfBTCInWallet = Int

data TradeTick = TradeTick
  { s :: !Text    -- Symbol (e.g., "BTCUSDT")
  , p :: !String  -- Price (Binance sends this as a string)
  } deriving (Show, Generic)

data BacktestTradeTick = BacktestTradeTick
  { btSymbol :: !Text
  , btPrice :: !BTCPrice
  , btDate :: !Text
  } deriving (Show, Generic)

instance FromJSON TradeTick

data Decision = Buy | Sell | Hold
  deriving (Show)

data BTCHistoricDayData = HistoryData 
  {unix :: String
  , date :: String
  , symbol :: String
  , open :: BTCPrice
  , high :: BTCPrice
  , low :: BTCPrice
  , close :: BTCPrice
  , volumeBTC :: Double 
  , volumeUSDT :: Double
  , tradecount :: Int
  } deriving (Show)
