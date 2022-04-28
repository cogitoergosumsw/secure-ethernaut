// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);

    // **VULNERABLE PORTION**
    // vulnerable to integer overflow/underflow
    // if the attacker only has 20 tokens, and it tries to transfer 21 tokens,
    // balances[msg.sender] will underflow to become a huge number because 20 - 21 != -1 but rather a hugeeeee number
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
