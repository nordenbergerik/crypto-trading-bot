module Bot.Accounting(updateBalance, updateWallet, roi) where

import Bot.Types(Balance, BTCPrice, Decision, NumOfBTCInWallet, Decision(..))



updateBalance :: Balance -> BTCPrice -> Decision -> Balance
updateBalance oldBalance price decision = 
    case decision of
        Buy  -> oldBalance - price
        Sell -> oldBalance + price
        Hold -> oldBalance

updateWallet :: NumOfBTCInWallet -> Decision -> NumOfBTCInWallet
updateWallet n decision =
    case decision of
        Buy  -> n+1
        Sell -> n-1
        Hold -> n
        

roi :: Balance -> NumOfBTCInWallet -> BTCPrice -> Balance -> Double
roi balance numOFBTCInWallet price initialBalance = let walletValue = balance + (fromIntegral numOFBTCInWallet * price) 
                                     in walletValue / initialBalance