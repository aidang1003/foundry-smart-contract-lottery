// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {console2} from "forge-std/console2.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract DeployRaffle is Script {
    HelperConfig public helperConfig;

    function run() public {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        helperConfig = new HelperConfig();
        // Local => deploy mocks, get local config
        // Sepolia => get Sepolia config
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        console2.log(
            "subscription Id ins Deploy Raffle script:",
            config.subscriptionId
        );

        if (config.subscriptionId == 0) {
            // create subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubscription
                .createSubscription(config.vrfCoordinator, config.account);

            console2.log(
                "Subscription Created with id:",
                config.subscriptionId
            );
            console2.log("Copy Subscription ID to your HelperConfig.s.sol"); // Don't want to create more subscription IDs

            helperConfig.setConfig(block.chainid, config);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                config.vrfCoordinator,
                config.subscriptionId,
                config.link,
                config.account,
                config.fundingAmount
            );
        }

        vm.startBroadcast(config.account);

        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        // Add contract as consumer after deploying
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId,
            config.account
        );

        return (raffle, helperConfig);
    }

    // function getSubscriptionBalance(
    //     HelperConfig.NetworkConfig memory config
    // ) public returns (uint96) {
    //     vm.startBroadcast(config.account);
    //     (uint96 subscriptionBalance, , , ) = VRFCoordinatorV2Interface(
    //         config.vrfCoordinator
    //     ).getSubscription(uint64(config.subscriptionId));
    //     vm.stopBroadcast();
    //     return subscriptionBalance;
    // }
}
