// SPDX-License-Identifier: MIT
// FIXME

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BaseSwapper {

    address public router;

    constructor(address _router) {
        router = _router;
    }

    function swap(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB) public {

    }
}