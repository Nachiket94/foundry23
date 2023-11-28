// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import { Test, console } from "lib/chainlink/contracts/foundry-lib/forge-std/src/Test.sol";
import { FundMe } from "src/FundMe.sol";
import { DeployFundme } from "script/Fundme.s.sol";

contract FundMeTest is Test{
  FundMe fundMe;

  address public USER = makeAddr("user");
  uint256 constant STARTING_BAL = 10 ether;
  uint256 constant SEND_VALUE = 0.1 ether;
  uint256 constant GAS_PRICE = 1;

  function setUp() external {
    DeployFundme deployer = new DeployFundme();
    fundMe = deployer.run();
    vm.deal(USER, STARTING_BAL);
  }

  function testMinDollarIsFive() public{
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwner() public{
    assertEq(fundMe.getOwner(), msg.sender);
  }

  function testFundFailsWithoutEnoughEth() public{
     vm.expectRevert();
     fundMe.fund();
  }

  function testFundUpdatesFundedDataStructure() public funded{
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
  }

  function testAddsFunderToArrayOfFunders() public funded{
    address funder = fundMe.getFunders(0);
    assertEq(funder, USER);
  }

  function testOnlyOwnerCanWithdraw() public funded{
    vm.prank(USER);
    vm.expectRevert();
    fundMe.withdraw();
  }

  function testWithdrawWithSingleFunder() public funded{
    uint256 startingOwnerBal = fundMe.getOwner().balance;
    uint256 startingFundMeBal = address(fundMe).balance;
    
    // uint256 gasStart = gasleft();
    vm.txGasPrice(GAS_PRICE);
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // uint256 gasEnd = gasleft();
    // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
    // console.log(gasUsed);

    uint256 endingOwnerBal = fundMe.getOwner().balance;
    uint256 endingFundMeBal = address(fundMe).balance;

    assertEq(endingFundMeBal, 0);
    assertEq(startingFundMeBal + startingOwnerBal, endingOwnerBal);
  }

  function testWithdrawFromMultipleFunders() public funded{
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;

    for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
      hoax(address(i), SEND_VALUE);
      fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingOwnerBal = fundMe.getOwner().balance;
    uint256 startingFundMeBal = address(fundMe).balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    assertEq(address(fundMe).balance, 0);
    assertEq(startingFundMeBal + startingOwnerBal, fundMe.getOwner().balance);
  }

    function testWithdrawFromMultipleFundersCheaper() public funded{
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;

    for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
      hoax(address(i), SEND_VALUE);
      fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingOwnerBal = fundMe.getOwner().balance;
    uint256 startingFundMeBal = address(fundMe).balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.cheaperWithdraw();
    vm.stopPrank();

    assertEq(address(fundMe).balance, 0);
    assertEq(startingFundMeBal + startingOwnerBal, fundMe.getOwner().balance);
  }

  modifier funded(){
    vm.prank(USER);
    fundMe.fund{value: SEND_VALUE}();
    _;
  }
}