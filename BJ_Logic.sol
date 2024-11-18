// SPDX-License-Identifier: FIGxx
pragma solidity 0.8.10;

import {bankContract} from "./investorBank.sol";
import {ArbSys} from "./arbitrumInterface.sol";

import {Data_BJ} from "./BJ_Data.sol";
import {Rules_BJ} from "./BJ_Rules.sol";
import {Contained_BJ} from "./BJ_Pure.sol";


contract Logic_BJ is Data_BJ, Rules_BJ {
    address public bankAddress;
    bankContract bank;
    
    ////////////////// MODIFIERS ////////////////////

        modifier primed {
            uint64 gameID = player[msg.sender].gameID;
            require(game[gameID].is_primed,"caller has not primed their next move");
            require(game[gameID].primedBlock + GRACE_PERIOD < getBlocknumber(),"caller has not waited out the grace period");
            require(!isBlockExpired(game[gameID].primedBlock),"prime has expired");
            _; //given function runs here
        }
        
        modifier hprimed {
            require(game[player[msg.sender].gameID].hit_primed,"caller is not primed to hit");
            _; //given function runs here
        }
        
        modifier sprimed {
            uint256 gameID = player[msg.sender].gameID;
            //change \/ for insurance
            //user doesnt need to prime if they've already lost 
            if(game[gameID].playerHand.value < 22){
                require(game[gameID].stand_primed,"caller is not primed to stand");
            }
            _; //given function runs here
        }

        modifier dprimed {
            require(game[player[msg.sender].gameID].double_primed,"caller is not primed to double");
            _; //given function runs here
        }

        modifier not_in_game {
            require(player[msg.sender].gameID == 0,"caller is currently in a game");
            _; //given function runs here
        }
        modifier is_in_game {
            require(player[msg.sender].gameID != 0,"caller is not in a game"); 

            _; //given function runs here
        }

        
    ////////////////// MODIFIERS ////////////////////
  
    function prime_move() internal {
        uint64 gameID = player[msg.sender].gameID;
        require(game[gameID].primedBlock == 0,"move is already primed");
        game[gameID].primedBlock = getBlocknumber();
        game[gameID].is_primed = true;
    }

    function un_prime(uint64 gameID) internal { 
        game_data storage Rgame = game[gameID];
        Rgame.is_primed = false;
        Rgame.hit_primed = false;
        Rgame.double_primed = false;
        Rgame.stand_primed = false;
        Rgame.primedBlock = 0;   
    }

    function un_prime(game_data storage Rgame) internal { 
        Rgame.is_primed = false;
        Rgame.hit_primed = false;
        Rgame.double_primed = false;
        Rgame.stand_primed = false;
        Rgame.primedBlock = 0;   
    }

    function deposit() internal { 
        //called by buy_in() and prime_double()
        require(msg.value % 2 == 0,"bet is not divisble by 2"); 
            
        bankFunds(msg.value);
        game[player[msg.sender].gameID].bet_value += msg.value;
    }

    function bankFunds(uint256 amount) internal {
        (bool success, ) = bankAddress.call{value: amount}("");
        require(success,"transfer was not successful");
    }

    function get_card(Hand storage hand, uint256 primedBlock) internal returns(uint8){
        uint8 ncard = new_card(primedBlock);

        unchecked { FACTOR += primedBlock; }
        
        (hand.value,hand.aces) = card_logic(ncard, hand.value, hand.aces);
        hand.cards.push(ncard);
        return ncard;
    }

    function payout(uint64 _gameID) internal {
        //updates the player's reward balance
        address _receiver = game[_gameID].player_address;
        uint256 _bet = game[_gameID].bet_value;

        uint8 _outcome = game[_gameID].outcome;

        uint256 reward;

        if(_outcome == 0){ //loss
            reward = 0;
        }
        else if (_outcome == 1){ 
            require(false,"ERROR, PAYOUT CALLED WITH DRAW OUTCOME, INSTEAD OF PUSH");
            //doesnt happen
            //TODO make this a push aka force a buyin 
            //call depo and deal
            reward = _bet;
        }
        else if (_outcome == 2){ //regular win
            reward = _bet * 2;


        }
        else if (_outcome == 3){ //BLACKJACK 3 to 2
            reward = blackjack_payout(_bet);

        } else /*if (_outcome == 4)*/{ //surrender aka the bet is divided in half, half is given to the house, half is given to the player
            reward = _bet / 2;
        }
        
        player[_receiver].earnings += reward;
        bank.set_rewards(reward,_receiver);
    }

    function internal_stand(uint64 gameID) internal {
        game_data storage Rgame = game[gameID];
        if(Rgame.playerHand.value < 22){
            while(Rgame.dealerHand.value < 17){
                get_card(Rgame.dealerHand, Rgame.primedBlock);
            }
        }

        uint8 result = check_result(Rgame.playerHand, Rgame.dealerHand);
        
        if(result > 1)
            player[msg.sender].wins++;
        else if (result == 1)
            player[msg.sender].ties++;
        
        Rgame.outcome = result;

        if(result != 1){
            payout(gameID); 
            player[Rgame.player_address].gameID = 0;
        } else {
            push(Rgame);
        }

        un_prime(Rgame);
    }

    function push(game_data storage Rgame) internal {
        address playerAdr = Rgame.player_address;

        uint64 new_gameID = uint64(game.length);
        game.push(new_game(playerAdr));
        player[playerAdr].gameID = new_gameID;
        player[playerAdr].gameID_list.push(new_gameID);

        game_data storage Ngame = game[new_gameID];
        Ngame.bet_value = Rgame.bet_value;
        Ngame.primedBlock = Rgame.primedBlock;
        Ngame.is_primed = true;

        deal_internal(new_gameID);
    }

    function deal_internal(uint64 gameID) internal returns(uint8,uint8,uint8){
        game_data storage Rgame = game[gameID];
        require(!Rgame.hit_primed && !Rgame.stand_primed && !Rgame.double_primed,"caller is not primed to deal"); 
        
        uint8 card1 = get_card(Rgame.playerHand,Rgame.primedBlock); 
        uint8 card2 = get_card(Rgame.playerHand,Rgame.primedBlock); 
        uint8 card3 = get_card(Rgame.dealerHand,Rgame.primedBlock);       
    
        if(Rgame.playerHand.value == 21){
            get_card(Rgame.dealerHand,Rgame.primedBlock);

            Rgame.outcome = check_result(Rgame.playerHand,Rgame.dealerHand); 
            payout(gameID);
            player[Rgame.player_address].gameID = 0;
        }

        un_prime(Rgame);
        return(card1,card2,card3);
    }


}

