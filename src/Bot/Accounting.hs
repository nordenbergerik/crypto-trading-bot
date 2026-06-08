module Bot.Accounting(updateBalance, updateWallet, roi) where

import Bot.Types(Balance(..), BTCPrice (BTCPrice), Decision, NumOfBTCInWallet, Decision(..))



updateBalance :: Balance -> BTCPrice -> Decision -> Balance
updateBalance (Balance oldBalance) (BTCPrice price) decision = 
    case decision of
        Buy  -> Balance (oldBalance - price)
        Sell -> Balance (oldBalance + price)
        Hold -> Balance oldBalance

updateWallet :: NumOfBTCInWallet -> Decision -> NumOfBTCInWallet
updateWallet n decision =
    case decision of
        Buy  -> n+1
        Sell -> n-1
        Hold -> n
        

roi :: Balance -> NumOfBTCInWallet -> BTCPrice -> Balance -> Double
roi (Balance balance) numOFBTCInWallet (BTCPrice price) (Balance initialBalance) = 
    let walletValue = balance + (fromIntegral numOFBTCInWallet * price) 
    in realToFrac (walletValue / initialBalance)