// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint) public balances;

  uint public constant threshold = 1 ether;
  uint public deadline = block.timestamp + 30 seconds;
  bool openForWithdraw = false;

  constructor(address exampleExternalContractAddress){
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  event Stake(address, uint);

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(msg.value >= 0.001 ether, "Not enough ether!");

    uint amount = msg.value;
    balances[msg.sender] += amount;
    emit Stake(msg.sender, amount);
  }

  function balance() public view returns(uint){
    return address(this).balance;
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public{
    require(block.timestamp >= deadline, "Not passed deadline yet!");

    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
    else {
      openForWithdraw = true;
    }
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  function withdraw(address payable _to) public {
    require(balances[_to] > 0, "You didn't stake anything!");

    (bool success, ) = _to.call{value: balances[_to]}("");
    require(success, "Failed to send Ether");
    delete balances[_to];
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint){
    if(block.timestamp >= deadline){
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()


}
