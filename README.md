# Blackjack-On-Chain
Blackjack-On-Chain is a decentralized application (dApp) that brings the popular game of Blackjack onto the blockchain. This project leverages smart contracts to ensure transparency, fairness, and immutability for all players. Built for EVM-chains with specific arbitrum integration

## Features
Decentralized Gameplay: All game logic is handled on-chain, ensuring fairness and trust.
True Randomness: Powered by Chainlink VRF for generating random numbers.
Player-Friendly Mechanics: Supports betting, card distribution, and game rules compliant with traditional Blackjack.
Modular Design: Separate smart contracts for logic, rules, and external interactions to enhance scalability and maintainability.
## Smart Contract Modules

### BJ_External.sol
Contains all external functions for the end user to interact with.

### BJ_Data.sol
Manages data storage for player sessions, game states, and results.

### BJ_Logic.sol
Implements the core game logic, including card dealing, hit/stand mechanics, and determining winners.

### BJ_Pure.sol
Contains pure functions for utility operations, ensuring gas efficiency.

### BJ_Rules.sol
Defines the rules of Blackjack, including bust checks, dealer behavior, and Blackjack scenarios.

### investorBank.sol
Facilitates financial interactions for investors and players, such as deposit/withdrawal mechanisms.

### arbitrumInterface.sol
Handles integration with the Arbitrum network for smooth and efficient interactions.

### ownable.sol
Provides ownership and administrative functionalities for managing the smart contract system.

## How to Deploy
1. Clone the project into remix.ethereum.org
2. Use the "Solidity compiler" tab to compile BJ_External.sol
3. Go to the "Deploy & run transactions" tab to deploy the contracts
4. Select an Environment to deploy to
5. Select "bankContract" and deploy it with some intintal funds to be used to payout rewards later on

   (By defualt all addresses will be authed to withdraw funds from the bank contract to make the setup prosscess easier, to disable this call the auth function and pass it the null address setting its auth status to false, then pass the address of the game contract you want to auth)

6. Select "BJ_External.sol", pass the bankContract adr as a parameter, and deploy it
7. 

