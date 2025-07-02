// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract testInteractions is Test {
    CreateSubscription public createSubscription;
    FundSubscription public fundSubscription;
    AddConsumer public addConsumer;

    uint256 public entranceFee;
    uint256 public interval;
    address public vrfCoordinator;
    bytes32 public gasLane;
    uint256 public subscriptionId;
    uint32 public callbackGasLimit;
    address public account;
    address public link;
    uint256 public fundingAmount;

    function setUp() external {
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsumer = new AddConsumer();

        HelperConfig.NetworkConfig memory config = new HelperConfig()
            .getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
        account = config.account;
        link = config.link;
        fundingAmount = config.fundingAmount;
    }

    function testCreatingSubscriptionIdUsingConfig() public {
        // Arrange
        (uint256 subId, ) = createSubscription.createSubscriptionUsingConfig();
        // Act / Assert
        assert(subId != 0);
    }

    function testAddingConsumerUsingConfig() public {
        // Arrange
    }

    function testGetSubscriptionBalanceReturnsNumberGreaterThanZero() public {
        // Arrange
        // Act
        uint256 subscriptionBalance = fundSubscription.getSubscriptionBalance(
            vrfCoordinator,
            account,
            subscriptionId
        );

        // Assert
        assert(subscriptionBalance > 0);
    }
}
