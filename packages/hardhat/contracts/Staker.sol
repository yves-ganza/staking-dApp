// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint) public balances;

  uint public constant threshold = 1 ether;
  uint public deadline = block.timestamp + 30 seconds;
  bool executed = false;


  constructor(address exampleExternalContractAddress){
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted(){
    require(!exampleExternalContract.completed(), "Staking Completed!");
    _;
  }

  event Stake(address, uint);


  function stake() public payable {
    require(!executed, "Goal reached , staking not allowed!");
    require(msg.value >= 0.001 ether, "Minimum 0.001 ether!");

    uint amount = msg.value;
    balances[msg.sender] += amount;
    emit Stake(msg.sender, amount);
  }

  function balance() public view returns(uint){
    return address(this).balance;
  }


  function execute() public notCompleted{
    require(block.timestamp >= deadline, "Can't execute before deadline!");

    require(address(this).balance >= threshold, "Threshold not reached yet, keep staking!");

    exampleExternalContract.complete{value: address(this).balance}();
    executed = true;
  }

  function withdraw(address payable _to) public notCompleted{
    require(balances[_to] > 0, "No contributions found for this address");

    (bool success, ) = _to.call{value: balances[_to]}("");
    require(success, "Failed to send Ether");
    delete balances[_to];
  }


  function timeLeft() public view returns(uint){
    if(block.timestamp >= deadline){
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  receive() external payable {
    stake();
  }

}
