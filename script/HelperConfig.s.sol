// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from
    "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 enteranceFee;
        uint256 interval;
        bytes32 gasLane;
        uint32 subscriptionId;
        uint32 callbackGasLimit;
        address vrfCoordinator;
    }

    NetworkConfig public activeNetwork;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetwork = getSepoliaEthConfig();
        } else {
            activeNetwork = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            enteranceFee: 0.001 ether,
            interval: 30,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callbackGasLimit: 50000,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetwork.vrfCoordinator != address(0)) {
            return activeNetwork;
        }
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(0.25 ether, 1e9);
        vm.stopBroadcast();
        return NetworkConfig({
            enteranceFee: 0.001 ether,
            interval: 30,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0,
            callbackGasLimit: 50000,
            vrfCoordinator: address(vrfCoordinatorV2Mock)
        });
    }
}
