// SPDX-License-Identifier: FIGxx
pragma solidity 0.8.10;

import {Ownable} from "C:/Users/smash/Desktop/RemixD/contracts/BlackJack_investor_files/ownable.sol";


contract Rules_BJ is Ownable {
    uint8 public max_bet_ratio = 3; //bet * max_bet_ratio < pool 

    function setMax_bet_ratio(uint8 newMax) external onlyOwner {
        require(newMax > 1,"max_bet_ratio must be greater than 1");
        max_bet_ratio = newMax;
    }

    bool public BJ32 = true;
    function blackjack_payout(uint256 _bet) internal view returns (uint256 reward){
        if(BJ32)
            // 3/2 * _bet
            return _bet + ((_bet * 3) / 2);
        else 
            // 6/5 * _bet
            return _bet + ((_bet * 6) / 5);
    }
    
    function set_BJ32(bool input) onlyOwner external {
        BJ32 = input;
    }
}

