// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {Test} from "forge-std/Test.sol";

contract testInteractions is Test {
    CreateSubscription public createSubscription;
    FundSubscription public fundSubscription;
    AddConsumer public addConsumer;

    function setUp() external {
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsumer = new AddConsumer();
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
}
