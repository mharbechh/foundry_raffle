// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    event RaffleEntred(address indexed sender);
    Raffle public raffle;
    HelperConfig public helperConfig;
    uint256 enteranceFee;
    uint256 interval;
    bytes32 gasLane;
    uint32 subscriptionId;
    uint32 callbackGasLimit;
    address vrfCoordinator;
    address public USER = makeAddr("sahbi");
    uint256 public constant USER_STARTING_BALANCE = 10 ether;
    uint256 public constant AMOUNT_SENDED = 1 ether;

    modifier funded() {
        vm.prank(USER);
        raffle.enterRaffle{value: AMOUNT_SENDED}();
        _;
    }

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (enteranceFee, interval, gasLane, subscriptionId, callbackGasLimit, vrfCoordinator) =
            helperConfig.activeNetwork();
        vm.deal(USER, USER_STARTING_BALANCE);
    }

    function testRaffleInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testEnterRaffleRevert() public {
        vm.prank(USER);
        vm.expectRevert();
        raffle.enterRaffle();
    }

    function testEnterRaffleSuccess() public {
        vm.prank(USER);
        raffle.enterRaffle{value: AMOUNT_SENDED}();
    }

    function testArrayIsUpdated() public funded {
        assertEq(raffle.getPlayerAddress(0), USER);
    }
    function testEventEmitted() public {
        vm.expectEmit(true, false, false, false);
        emit RaffleEntred(USER);
        vm.prank(USER);
        raffle.enterRaffle{value: 1 ether}();
        
    }
}
