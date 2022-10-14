// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "../BaseSwapper.sol";

contract CurveSwapper is BaseSwapper {
    // FIXME
    constructor(address _router) BaseSwapper(_router) {
        router = _router;
    }
}
