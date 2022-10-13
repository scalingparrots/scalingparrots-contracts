// SPDX-License-Identifier: MIT
// FIXME

pragma solidity ^0.8.9;

import "../BaseSwapper.sol";

contract UniswapV3Swapper is BaseSwapper {

    constructor(address _router) BaseSwapper(_router) {
        router = _router;
    }
}