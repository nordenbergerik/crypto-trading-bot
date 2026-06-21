module Bot.ROI (roiIfBuyAndHold) where

import Bot.Types (Balance (..), BTCPrice (..))
import Control.Exception (try, catch, IOException)

roiIfBuyAndHold :: Balance -> IO (Maybe Double)
roiIfBuyAndHold (Balance initialBalance) = do
    btcDataResult <- tryReadFile "data/BTCUSDT_Binance_futures_UM_hour.csv"
    case btcDataResult of
        Left e        -> return Nothing
        Right btcData -> do
            let dataLines = lines btcData 
            let firstLine = head dataLines
            let lastLine = last dataLines
            let initialPrice = BTCPrice (read ((wordsWhen (==',') firstLine) !! 2))
            let finalPrice = BTCPrice (read ((wordsWhen (==',') lastLine) !! 2))
            let numOfCoins = realToFrac initialBalance / realToFrac initialPrice
            return $ Just ((realToFrac finalPrice - realToFrac initialPrice) * numOfCoins)

tryReadFile :: FilePath -> IO (Either IOException String)
tryReadFile path = (Right <$> readFile path) `catch` (return . Left)

wordsWhen :: (Char -> Bool) -> String -> [String]
wordsWhen p s =  case dropWhile p s of
                      "" -> []
                      s' -> w : wordsWhen p s''
                            where (w, s'') = break p s'
