# Blackjack-On-Chain
Blackjack-On-Chain is a decentralized application (dApp) that brings the popular game of Blackjack onto the blockchain. This project leverages smart contracts to ensure transparency, fairness, and immutability for all players. Built on the Arbitrum network, the system utilizes Chainlink VRF for true randomness, ensuring trustless gameplay.

## Features
Decentralized Gameplay: All game logic is handled on-chain, ensuring fairness and trust.
True Randomness: Powered by Chainlink VRF for generating random numbers.
Player-Friendly Mechanics: Supports betting, card distribution, and game rules compliant with traditional Blackjack.
Modular Design: Separate smart contracts for logic, rules, and external interactions to enhance scalability and maintainability.
## Smart Contract Modules
### arbitrumInterface.sol
Handles integration with the Arbitrum network for smooth and efficient interactions.

### BJ_Data.sol
Manages data storage for player sessions, game states, and results.

### BJ_External.sol
Contains all external functions for the end user to interact with.

### BJ_Logic.sol
Implements the core game logic, including card dealing, hit/stand mechanics, and determining winners.

### BJ_Pure.sol
Contains pure functions for utility operations, ensuring gas efficiency.

### BJ_Rules.sol
Defines the rules of Blackjack, including bust checks, dealer behavior, and Blackjack scenarios.

### investorBank.sol
Facilitates financial interactions for investors and players, such as deposit/withdrawal mechanisms.

### ownable.sol
Provides ownership and administrative functionalities for managing the smart contract system.

## How to Use

