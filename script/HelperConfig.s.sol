// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "@chainlink/contracts/foundry-lib/forge-std/src/Script.sol";
import { MockV3Aggregator } from "test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
  NetworkConfig public activeNetwrokConfig;
  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e18;

  struct NetworkConfig{
    address priceFeed;
  }

  constructor(){
    if(block.chainid == 11155111){
      activeNetwrokConfig = getSepoliaEthConfig();
    } 
    else if(block.chainid == 31337){
      activeNetwrokConfig = getAnvilEthConfig();
    }
  }
  function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
    NetworkConfig memory sepoliaConfig = NetworkConfig({
      priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    });
    return sepoliaConfig;
  }

  function getAnvilEthConfig() public returns (NetworkConfig memory){
    // if (activeNetwrokConfig.priceFeed != address(0)){
    //   return activeNetwrokConfig;
    // }
    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockPriceFeed)
    });

    return anvilConfig;
  }
}