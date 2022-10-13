// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IBaseERC20.sol";

interface IMintbleERC20 is IBaseERC20 {
    function mint(uint256 _amount) external;
}
