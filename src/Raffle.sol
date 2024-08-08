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
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
    error Raffle__NotEnoughEthSended();
    error Raffle__UpKeepNotNeeded(uint256 balance, uint256 raffleState, uint256 players);

    enum RaffleState {
        OPEN,
        CALCULATE
    }
    //chainlink variable

    bytes32 private i_keyHash;
    uint64 private i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint32 private immutable i_callbackGasLimit;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;

    // lottery variable

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    address payable s_lastWinner;
    RaffleState private s_raffleState;
    //events

    event RaffleEntred(address indexed sender);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 enteranceFee,
        uint256 interval,
        bytes32 gasLane,
        uint32 subscriptionId,
        uint32 callbackGasLimit,
        address vrfCoordinator
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = enteranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) revert Raffle__NotEnoughEthSended();
        require(s_raffleState == RaffleState.OPEN, "cannot enter Raffle NOW");
        s_players.push(payable(msg.sender));
        emit RaffleEntred(msg.sender);
    }

    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        bool isTime = block.timestamp - s_lastTimeStamp > i_interval;
        bool isBalance = address(this).balance > 0;
        bool isPlayers = s_players.length > 0;
        bool isOpen = s_raffleState == RaffleState.OPEN;
        upkeepNeeded = (isTime && isBalance && isPlayers && isOpen);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */ ) external {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpKeepNotNeeded(address(this).balance, uint256(s_raffleState), s_players.length);
        }
        s_raffleState = RaffleState.CALCULATE;
        i_vrfCoordinator.requestRandomWords(
            i_keyHash, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, NUM_WORDS
        );
    }

    function fulfillRandomWords(uint256, /* requestId */ uint256[] memory randomWords) internal override {
        uint256 indexWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexWinner];
        s_lastWinner = winner;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
        (bool success,) = winner.call{value: address(this).balance}("");
        require(success, "transfer failed");
        emit WinnerPicked(winner);
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayerAddress(uint256 _index) external view returns (address) {
        return s_players[_index];
    }
}
