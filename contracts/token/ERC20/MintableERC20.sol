// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./BaseERC20.sol";

contract MintableERC20 is BaseERC20 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender));
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _amount
    ) BaseERC20(_name, _symbol, _amount) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(msg.sender, _amount * 10**decimals());
    }

    function mint(uint256 _quantity) public onlyMinter {
        _mint(msg.sender, _quantity);
    }

    function changeMinter(address _newMinter) public onlyMinter {
        _grantRole(DEFAULT_ADMIN_ROLE, _newMinter);
    }
}
