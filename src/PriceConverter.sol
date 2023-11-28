// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
  function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){
    (,int256 answer,,,) = priceFeed.latestRoundData();
    return uint256(answer * 1e10);
  }

  function getConvertedRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256){
    uint256 priceOfEth = getPrice(priceFeed);
    return (priceOfEth * ethAmount) / 1e18;
  }

  function getDecimals(AggregatorV3Interface priceFeed) internal view returns(uint8){
    uint8 decimals = priceFeed.decimals();
    return decimals;
  }

  function getVersion(AggregatorV3Interface priceFeed) internal view returns(uint256){
    uint256 version = priceFeed.version();
    return version;
  }
}

// 0x694AA1769357215DE4FAC081bf1f309aDC325306