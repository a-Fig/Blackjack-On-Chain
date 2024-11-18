// SPDX-License-Identifier: FIGxx
pragma solidity 0.8.10;

import {bankContract} from "./investorBank.sol";
import {Logic_BJ} from "./BJ_Logic.sol";

contract Blackjack_Game is Logic_BJ {

    constructor(address payable _bankAddress) {
        bank = bankContract(_bankAddress);
        bankAddress = _bankAddress;
        
        game.push();
    }

    //claim_rewards()
    function claim_rewards() external {
        bank.claim_rewards(payable(msg.sender));
    }

    function unclaimed_rewards() external view returns(uint256 reward_balance){
        return bank.rewards(msg.sender);
    }

    //start new game, prime deal
    function buy_in() external payable not_in_game {
        require(bank.deposit_pool() >= ((msg.value+game[player[msg.sender].gameID].bet_value) * max_bet_ratio)
        ,"bet is to large for the pool"); //use to be in depo()

        uint64 new_gameID = uint64(game.length);
        player[msg.sender].gameID = new_gameID;
        player[msg.sender].gameID_list.push(new_gameID);
        game.push(new_game());

        prime_move();
        deposit();
    }

    //deals out intail cards 
    function deal() external primed returns(uint8,uint8,uint8){
        return(deal_internal(player[msg.sender].gameID));
    }

    //hit()
    function hit() external hprimed primed is_in_game returns(uint8, uint8){
        uint64 gameID = player[msg.sender].gameID;
        game_data storage Rgame = game[gameID]; 
        uint8 ncard = get_card(Rgame.playerHand,Rgame.primedBlock);            

        
        if(Rgame.playerHand.value >= 21){
            internal_stand(player[msg.sender].gameID);
        }

        un_prime(Rgame);
        return (ncard,Rgame.playerHand.value);
    }

    //stand()
    function stand() public sprimed primed is_in_game {
        internal_stand(player[msg.sender].gameID);
    }

    //double()
    //
    function double() external dprimed primed is_in_game returns (uint8){ 
        uint64 gameID = player[msg.sender].gameID;                
        uint8 ncard = get_card(game[gameID].playerHand,game[gameID].primedBlock);  

        internal_stand(gameID);
        return (ncard);
    }

    //surrender()
    //surrender requires no priming because it does not generate new cards
    function surrender() external { //TODO test
        uint64 gameID = player[msg.sender].gameID;
        game_data storage Rgame = game[gameID];
        require(!Rgame.is_primed,"caller is primed for a different move");
        require(Rgame.playerHand.cards.length == 2, "you can't surrender with more than 2 cards");

        Rgame.outcome = 4;

        payout(gameID);
        player[msg.sender].gameID = 0;  
        un_prime(gameID);
    }

    //forfeit()
    //ends game no matter what 
    function forfeit() is_in_game external {
        game[player[msg.sender].gameID].outcome = 5;

        player[msg.sender].gameID = 0;
        un_prime(player[msg.sender].gameID);
    }

    function insurance() external {

    }
    //prime_hit()
    function prime_hit() external is_in_game {
        game_data storage Rgame = game[player[msg.sender].gameID];
        require(Rgame.playerHand.value < 21,"user's hand is too big and can no longer hit");
        Rgame.hit_primed = true;
        prime_move();
    }

    //prime_double() 
    function prime_double() external payable is_in_game {
        game_data storage Rgame = game[player[msg.sender].gameID];
        require(Rgame.playerHand.value < 21,"user's hand is too big and can no longer hit or double");
        require(msg.value == Rgame.bet_value, "you must double the size of your inital bet to double");
        require(Rgame.playerHand.cards.length == 2, "you can't double with more than 2 cards");

        Rgame.double_primed = true;

        deposit();
        prime_move();
    }

    //prime_stand()
    function prime_stand() public is_in_game {
        game[player[msg.sender].gameID].stand_primed = true;
        prime_move();
    }



}
