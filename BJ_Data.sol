// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {Contained_BJ} from "./BJ_Pure.sol";


contract HandData {
    struct Hand {
        uint8 value;
        uint8 aces;
        uint8[] cards;
    }
}

contract GameData is HandData, Contained_BJ  {
    game_data[/*takes gameID*/] public game; 
    struct game_data { //how info on games is stored
        address player_address; //which address is playing this game

        uint256 bet_value;
        
        Hand playerHand; //var name player is used twice change one //this can be stored as an array to hold multiple player hands for splits //hands and bets would have to be stored togther
        Hand dealerHand;

        //primes
        bool is_primed;         
        bool hit_primed;        
        bool stand_primed;      
        bool double_primed;

        uint256 primedBlock;

        //bool isActive = (outcome == 9);
        uint256 last_play; //the block_number of the last move on this game
        uint8 outcome; //stores the outcome of the game 
        /*
        0 = loss
        1 = draw/push 
        2 = win 
        3 = Blackjack 
        4 = surrender 
        5 = forfeit 
        9 = undefinded
        */
    }

    function new_game(address playerAddress) /*game_data Constructor*/ view internal returns(game_data memory newGame){ 
        game_data memory Lgame; //Lgame = local game

        Lgame.player_address = playerAddress;
        Lgame.last_play = getBlocknumber();
        Lgame.outcome = 9;

        return Lgame;
        /*
        \/ HOW TO USE new_game(); \/

        player[msg.sender].active_gameID = allGames.length;
        allGames.push(new_game());
        */
    }
    function new_game() /*game_data Constructor*/ view internal returns(game_data memory x){ 
        return new_game(msg.sender);
    }
}

contract PlayerData {
    mapping(address => player_data) public player;

    function getPlayerData(address adr) external view returns
    (   uint64 GameID,
        uint64[] memory GameID_list,
        uint32 Wins, 
        uint32 Ties, 
        uint256 Earnings
    ) {
        return(
            player[adr].gameID,
            player[adr].gameID_list,
            player[adr].wins,
            player[adr].ties,
            player[adr].earnings
        );
    }

    struct player_data{ //how info on players is stored
        uint64 gameID; //should return 0 when player is not in a game
        uint64[] gameID_list; //stores the number that can be used to point to a game in games

        //general player stats
        uint32 wins; 
        uint32 ties; 
        uint256 earnings; 
    }
    
}

contract Data_BJ is GameData, PlayerData {
    
    function adrGameID(address adr) internal view returns (uint256) {
        return player[adr].gameID;
    }

    function card_logic(uint8 ncard, uint8 hand_value, uint8 aces) internal pure returns(uint8 _hand_value, uint8 _aces) {
        uint8 card_value;

        //sets face cards and 10 equal to 10
        if(ncard > 9) {
            card_value = 10;
        }
        //sets ace's equal to 11, and adds to ace value so it can be removed later
        else if (ncard == 1){
            card_value = 11;
            aces++;
        }
        //sets the value of the remaining cards equal to there number
        else{
            card_value = ncard;
        }

        hand_value += card_value;

        //if they're gonna bust
        if (hand_value > 21 && aces > 0){
            hand_value -= 10;
            aces--;
        }

        return (hand_value, aces);
    }

    function check_result(Hand memory playerHand, Hand memory dealerHand) internal pure returns(uint8){
        uint8 _result;

        if(playerHand.value > 21){
            _result = 0;  
        }
        else if(dealerHand.value > 21){
            _result = 2;
        }
        else if(dealerHand.value == 21 && dealerHand.cards.length == 2){
            if(playerHand.value == 21 && playerHand.cards.length == 2){
                _result = 1;
            }
            else{
                _result = 0;
            }
        }
        else if(playerHand.value == 21 && playerHand.cards.length == 2){
            _result = 3;
        }
        else if(playerHand.value > dealerHand.value){
            _result = 2;
        }
        else if(playerHand.value == dealerHand.value){
            _result = 1;
        }
        else {
            _result = 0;
        }
        return _result;
    }

}