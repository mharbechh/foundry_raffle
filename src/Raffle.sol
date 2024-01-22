// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
/**
 * @title Raffle contract
 * @author Sahbi bayar
 * @notice a sample raffle contract like a game we pick winner at the end
 * @dev will implement chainlink vrf and chainlink automation
 */

contract Raffle {
    error Raffle__NotEnoughEthSended();
    // lottery variable

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    //events

    event RaffleEntred(address sender);

    constructor(uint256 enteranceFee) {
        i_entranceFee = enteranceFee;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthSended();
        s_players.push(payable(msg.sender));
        emit RaffleEntred(msg.sender);
    }
}
