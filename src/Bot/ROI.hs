module Bot.ROI (roiIfBuyAndHold, tryReadFile) where

import Bot.Types (Balance (..))
import Control.Exception (catch, IOException)
import Data.Maybe (isJust)
import Text.Read (readMaybe)
import Data.List (sortBy)
import Data.Ord (comparing)


-- roiIfBuyAndHold :: Balance -> IO (Maybe Double)
-- roiIfBuyAndHold initialBalance = do
--     btcDataResult <- tryReadFile "data/BTCUSDT_Binance_futures_UM_hour.csv"
--     case btcDataResult of
--         Left _ -> return Nothing
--         Right btcData -> do
--             let csvLines = drop 2 $ filter (not . null) (lines btcData)
--             let parsedLines = map (wordsWhen (== ',')) csvLines
--             let validLines = filter ((>= 7) . length) parsedLines
--             let firstLine = find (\parts -> isJust $ tryParseDouble (parts !! 6)) validLines
--             let lastLine = find (\parts -> isJust $ tryParseDouble (parts !! 6)) $ reverse validLines
--             case (firstLine, lastLine) of
--                 (Just fl, Just ll) ->
--                     case (tryParseDouble (fl !! 6), tryParseDouble (ll !! 6)) of
--                         (Just initialPrice, Just finalPrice) ->
--                             if initialPrice > 0 && finalPrice > 0
--                                 then do
--                                     let initialBalanceDouble = realToFrac initialBalance :: Double
--                                     let shares = initialBalanceDouble / initialPrice
--                                         finalValue = shares * finalPrice
--                                         roi = (finalValue - initialBalanceDouble) / initialBalanceDouble
--                                     return $ Just (roi * 100)
--                                 else return Nothing
--                         _ -> return Nothing
--                 _ -> return Nothing

roiIfBuyAndHold :: Balance -> IO (Maybe Double)
roiIfBuyAndHold initialBalance = do
    btcDataResult <- tryReadFile "data/BTCUSDT_Binance_futures_UM_hour.csv"
    case btcDataResult of
        Left _ -> return Nothing
        Right btcData -> do
            let csvLines = drop 2 $ filter (not . null) (lines btcData)
            let parsedLines = map (wordsWhen (== ',')) csvLines
            let validLines = filter ((>= 7) . length) parsedLines

            -- keep only rows where both Unix (col 0) and Close (col 6) parse
            let withTimestamp =
                    [ (unixVal, parts)
                    | parts <- validLines
                    , Just unixVal <- [tryParseDouble (parts !! 0)]
                    , isJust (tryParseDouble (parts !! 6))
                    ]

            if null withTimestamp
                then return Nothing
                else do
                    let sorted = sortBy (comparing fst) withTimestamp
                        (_, firstRow) = head sorted   -- earliest timestamp
                        (_, lastRow)  = last sorted    -- latest timestamp

                    case (tryParseDouble (firstRow !! 6), tryParseDouble (lastRow !! 6)) of
                        (Just initialPrice, Just finalPrice) ->
                            if initialPrice > 0 && finalPrice > 0
                                then do
                                    let initialBalanceDouble = realToFrac initialBalance :: Double
                                        shares = initialBalanceDouble / initialPrice
                                        finalValue = shares * finalPrice
                                        roi = (finalValue - initialBalanceDouble) / initialBalanceDouble
                                    return $ Just (roi * 100)
                                else return Nothing
                        _ -> return Nothing

tryParseDouble :: String -> Maybe Double
tryParseDouble s = readMaybe s

tryReadFile :: FilePath -> IO (Either IOException String)
tryReadFile path = (Right <$> readFile path) `catch` (return . Left)

wordsWhen :: (Char -> Bool) -> String -> [String]
wordsWhen p s = case dropWhile p s of
    "" -> []
    s' -> w : wordsWhen p s''
        where (w, s'') = break p s'
