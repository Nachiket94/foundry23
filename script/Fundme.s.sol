// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/chainlink/contracts/foundry-lib/forge-std/src/Script.sol";
import "../src/FundMe.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployFundme is Script {
    function run() external returns(FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetwrokConfig();

        vm.startBroadcast();
        FundMe convert = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return convert;
    }
}
