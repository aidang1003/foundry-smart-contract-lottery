// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Test} from "forge-std/Test.sol";

contract TestDeployRaffle is Test {
    DeployRaffle public deployRaffle;

    function setUp() public {
        deployRaffle = new DeployRaffle();
    }
}
