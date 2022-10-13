// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BaseERC20 is ERC20, AccessControl {

    constructor(uint256 _initialQuantity) ERC20("name", "symbol") {
        _mint(msg.sender, _initialQuantity * 10 ** decimals());
    }

}