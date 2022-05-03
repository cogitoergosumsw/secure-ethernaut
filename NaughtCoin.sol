// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NaughtCoin is ERC20 {
    // string public constant name = 'NaughtCoin';
    // string public constant symbol = '0x0';
    // uint public constant decimals = 18;
    uint256 public timeLock = now + 10 * 365 days;
    uint256 public INITIAL_SUPPLY;
    address public player;

    constructor(address _player) public ERC20("NaughtCoin", "0x0") {
        player = _player;
        INITIAL_SUPPLY = 1000000 * (10**uint256(decimals()));
        // _totalSupply = INITIAL_SUPPLY;
        // _balances[player] = INITIAL_SUPPLY;
        _mint(player, INITIAL_SUPPLY);
        emit Transfer(address(0), player, INITIAL_SUPPLY);
    }

    function transfer(address _to, uint256 _value)
        public
        override
        lockTokens
        returns (bool)
    {
        super.transfer(_to, _value);
    }

    // Prevent the initial owner from transferring tokens until the timelock has passed
    modifier lockTokens() {
        if (msg.sender == player) {
            require(now > timeLock);
            _;
        } else {
            _;
        }
    }
}

// ---SOLUTION---

// *need to run the functions on the console as the player to empty the balance of the NaughtCoin (cannot run functions via another contract)
// 1. check the balanceOf(player) of the NaughtCoin 
// e.g. `(await contract.balanceOf(player)).toString()`

// 2. check the spending allowance of the player 
// e.g. `(await contract.allowance(player, player)).toString()`, it should be zero -> we need to increase the spending allowance

// 3. increase the spending allowance of the player 
// e.g. `await contract.increaseAllowance(player, "1000000000000000000000000")`

// 4. transfer the tokens to some other account using the transferFrom() function
// e.g. `await contract.transferFrom("0x1BC3F80E636aCA18AeAF39494Bc6937AAEB9f076", "0xE425de99B7C0CA328Fc72EC3a377f98510d21e1C", "1000000000000000000000000")`
// note that we are using the transferFrom() function instead of the transfer() function written in the NaughtCoin contract 
// because the transfer() function inherits the ERC20 contract and has a modifier that checks for the timeLock (i.e. 10 years after contract creation)