// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Vault {
    // **VULNERABLE PORTION**
    // password is stored as private variable in the smart contract which can be easily read!
    // slot 0 contains bool variable which takes up 1 byte
    bool public locked;
    // slot 1 contains the password which occupy the full 32 bits slot
    bytes32 private password;

    // to regenerate the password, run the following command in the console,
    // await web3.eth.getStorageAt("0x2d8EA9e7f161393A6DEAb186aA539FEfCD754D75", 1, console.log)
    // you will get back a bytes32 string like this - 0x412076657279207374726f6e67207365637265742070617373776f7264203a29
    // convert the bytes32 string to ASCII and you'll get the actual password - 'A very strong secret password :)'

    constructor(bytes32 _password) public {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}
