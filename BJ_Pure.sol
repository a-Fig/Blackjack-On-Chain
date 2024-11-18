// SPDX-License-Identifier: FIGxx
pragma solidity 0.8.10;

import {ArbSys} from "./arbitrumInterface.sol";

contract Contained_BJ {
    uint8 constant GRACE_PERIOD = 3; //the higher the number, the more secure it is. new_card code is written for 3 blocks

    bool constant USING_ARBITRUM_BLOCKS = false; 
    ArbSys A = ArbSys(address(100));

    uint256 FACTOR = 57896044618658097719963;
    

    //new_card()
    //This function generates a card just like DEPRECATEDnew_card but it uses a different algo to have each of the 3 different blocks 
    //Contribute to the generation of the card in a unique way so that any one block doesnt have the power to generate a totaly different card
    //the first block creates an array of 9 cards, 
    //second block picks 3 from the 9
    //thrid picks 1 from the 3
    //because block 3 picks then Nth card from block 2, and block 2 picks the Ith card from block 1, we only need to calculate third[ i[n] ]
    
    function new_card(uint256 _block) internal view returns(uint8){
        bytes32 _blockhash = getBlockhash(_block + 3);
        uint8 rand3 = uint8((uint256(keccak256(abi.encodePacked(_blockhash,FACTOR)))%3));//this can only ever return 1 of the 3 cards

        _blockhash = getBlockhash(_block + 2);
        uint8 rand2 = uint8((uint256(keccak256(abi.encodePacked(_blockhash,FACTOR+rand3)))%9)); //this can only ever return 3 of the 9 cards

        _blockhash = getBlockhash(_block + 1);
        return uint8(1+(uint256(keccak256(abi.encodePacked(_blockhash,FACTOR+rand2)))%13)); //this can only ever return 9 of the 13 cards
    }

    function isBlockExpired(uint256 primedBlock) internal view returns (bool){
        uint8 max_idle_time = 255;
                                            //checks if the last play oppurtnity in the past
        return (primedBlock + max_idle_time < getBlocknumber() && primedBlock != 0);
    } 

    function getBlocknumber() internal view returns (uint256){
        //This is to allow the contract to use Arbitrum blocks, if this is to be used on a L1, replace all getBlocknumber with block.number
        if (USING_ARBITRUM_BLOCKS){
            return A.arbBlockNumber();
        }
        return block.number;
    }

    function getBlockhash(uint256 _blocknum) internal view returns (bytes32) {
        //This is to allow the contract to use Arbitrum blockhashes, if this contract is to be used on a L1, replace all getBlockhash with blockhash(x)
        if (USING_ARBITRUM_BLOCKS){
            return A.arbBlockHash(_blocknum);
        }
        return blockhash(_blocknum);
    }
}
