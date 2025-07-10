// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../../test/mocks/LinkToken.sol";
import {console2} from "forge-std/console2.sol";

contract testInteractions is Test {
    CreateSubscription public createSubscription;
    FundSubscription public fundSubscription;
    AddConsumer public addConsumer;

    LinkToken link;
    uint256 public constant LINK_BALANCE = 300 ether;

    uint256 public entranceFee;
    uint256 public interval;
    address public vrfCoordinator;
    bytes32 public gasLane;
    uint256 public subscriptionId;
    uint32 public callbackGasLimit;
    address public account;
    address public linkAddress;
    uint256 public fundingAmount;

    function setUp() external {
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsumer = new AddConsumer();

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
        account = config.account;
        fundingAmount = config.fundingAmount;
        link = LinkToken(config.link);

        vm.startPrank(msg.sender);
        if (block.chainid == helperConfig.LOCAL_CHAIN_ID()) {
            console2.log("Executing address", msg.sender);
            link.mint(msg.sender, LINK_BALANCE);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                LINK_BALANCE
            );
        }
        //link.approve(vrfCoordinator, LINK_BALANCE);
        vm.stopPrank();
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
