// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

contract Ownable {
    address payable public owner;

    modifier onlyOwner {
        require(msg.sender == owner ,"caller is not owner");
        _; //given function runs here
    }

}