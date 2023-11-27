// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import { Test } from "lib/chainlink/contracts/foundry-lib/forge-std/src/Test.sol";
import { FundMe } from "src/FundMe.sol";
import { DeployFundme } from "script/Fundme.s.sol";

contract FundMeTest is Test{
  FundMe fundMe;
  function setUp() external {
    DeployFundme deployer = new DeployFundme();
    fundMe = deployer.run();
  }

  function testMinDollarIsFive() public{
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwner() public{
    assertEq(fundMe.i_owner(), msg.sender);
  }
}