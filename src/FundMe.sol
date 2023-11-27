// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { PriceConverter } from "./PriceConverter.sol";

error Not__Owner();

contract FundMe {
  using PriceConverter for uint256;  

  mapping(address => uint256) public addressToAmountFunded;
  address[] public funders;
  address public i_owner;
  uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
  AggregatorV3Interface private s_priceFeed;

  constructor(address priceFeed){
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeed);
  }

  function fund() public payable{
    require(msg.value.getConvertedRate(s_priceFeed) >= MINIMUM_USD, "You didn`t send enough ETH");
    addressToAmountFunded[msg.sender] += msg.value;
    funders.push(msg.sender);
  }

  modifier onlyOwner {
    if(msg.sender != i_owner) revert Not__Owner();
    _;
  }

  function withdraw() public onlyOwner {
      for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
        address funder = funders[funderIndex];
        addressToAmountFunded[funder] = 0;
      }
      funders = new address[](0);
      (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
      require(callSuccess, "Call failed");
  }

  fallback() external payable {
    fund();
  }

  receive() external payable {
    fund();
  }
}