// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BaseERC20 is ERC20, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender));
        _;
    } 

    constructor(uint256 _amount) ERC20("name", "symbol") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(msg.sender, _amount * 10 ** decimals());
    }

    function mint(uint256 _quantity) public onlyMinter() {
        _mint(msg.sender, _quantity);
    }

    function changeMinter(address _newMinter) public onlyMinter() {
        _grantRole(DEFAULT_ADMIN_ROLE, _newMinter);
    }

}