// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeConstants {
    /* VRF Mock Values */
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    // LINK / ETH price
    int256 public MOCK_WEI_PER_UINT_LINK = 4e15;

    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionId;
        address link;
        address account;
    }

    // i_callbackGasLimit = callbackGasLimit;
    // s_lastTimeStamp = block.timestamp;
    // s_raffleState = RaffleState.OPEN;

    NetworkConfig public localNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfigs;
    address public constant FOUNDRY_DEFAULT_SENDER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function setConfig(
        uint256 chainId,
        NetworkConfig memory networkConfig
    ) public {
        networkConfigs[chainId] = networkConfig;
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainID(block.chainid);
    }

    function getConfigByChainID(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30, // every 30 seconds
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B, // https://docs.chain.link/vrf/v2-5/supported-networks
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // 500 gwei key hash
                callbackGasLimit: 500000, // 500,000 gas
                subscriptionId: 4286828711899728779972403595352076061476510105373236979072801134783610114273,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                account: 0x31Fdeb452632Cb502bF145B275E0F0d98C4732D6
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            console2.log("Using existing local netowrk config");
            return localNetworkConfig;
        }
        console2.log("Generating local netowrk config");

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );
        LinkToken linkToken = new LinkToken();
        uint256 subscriptionId = vrfCoordinatorMock.createSubscription();
        vm.stopBroadcast();

        console2.log("Helper config Subscription id: ", subscriptionId);
        console2.log(
            "Helper config vrfCoordinator mock address: ",
            address(vrfCoordinatorMock)
        );

        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30, // every 30 seconds
            vrfCoordinator: address(vrfCoordinatorMock), // Mock contract address
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // 500 gwei key hash
            callbackGasLimit: 500000, // 500,000 gas
            subscriptionId: subscriptionId,
            link: address(linkToken),
            account: FOUNDRY_DEFAULT_SENDER
        });

        return localNetworkConfig;
    }
}
