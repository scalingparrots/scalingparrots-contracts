// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract VeToken is ERC20, ERC20Burnable, AccessControl {
    using SafeMath for uint256;

    struct Lock {
        uint256 lockAmount;
        uint256 unlockDate;
    }

    address public baseToken;
    uint256 _precision = 10 ** 18;
    uint256 public maxLock;
    uint256 public minLock;

    mapping(address => Lock[]) private _tokenLock;
    
    event Deposit(address, uint256);
    event Withdraw(address, uint256);

    constructor(address _baseToken, uint256 _minDaysLock, uint256 _maxYearsLock) ERC20("voting escrow JDOE","veJDOE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        baseToken = _baseToken;
        maxLock = _maxYearsLock * 365 * 86400;
        minLock = _minDaysLock * 86400;
    }

    function getLocksByAddr(address _addr) public view returns (Lock[] memory) {
        return _tokenLock[_addr];
    }

    function deposit(uint256 amount, uint256 locktime) public returns (bool) {
        require(locktime > block.timestamp, "locktime is not valid");
        if(locktime >= block.timestamp.add(maxLock)) {
            locktime = block.timestamp.add(maxLock);
        }
        ERC20(baseToken).transferFrom(msg.sender, address(this), amount);
        _tokenLock[msg.sender].push(Lock(amount, locktime));
        _mint(msg.sender, amount);
        emit Deposit(msg.sender, amount);

        return true;
    }

    function withdraw(uint256 lockId) public returns (bool) {
        Lock[] storage _locks = _tokenLock[msg.sender];
        Lock memory _lock = _locks[lockId];
        require(_lock.unlockDate <= block.timestamp, "locktime is not expired");
        uint256 _lockedAmount = _lock.lockAmount;
        _burn(msg.sender, _lockedAmount);
        ERC20(baseToken).transfer(msg.sender, _lockedAmount);
        _locks[lockId] = _locks[_locks.length - 1];
        _locks.pop();
        emit Withdraw(msg.sender, _lockedAmount);
        
        return true;
    }

    function lockedBalanceOf(address _addr) public view virtual returns (uint256) {
        Lock[] memory locks = getLocksByAddr(_addr);
        uint256 _lockedBalance = 0;
        for(uint256 i = 0; i < locks.length; i++) {
            _lockedBalance = _lockedBalance.add(locks[i].lockAmount);
        }
        return _lockedBalance;
    }

    function votingPowerOf(address _addr) public view virtual returns (uint256) {
        Lock[] memory locks = getLocksByAddr(_addr);
        uint256 _votingBalance = 0;
        for(uint256 i = 0; i < locks.length; i++) {
            uint256 _unlockDate = locks[i].unlockDate;
            if(block.timestamp >= _unlockDate) continue;
            uint256 _lockAmount = locks[i].lockAmount;
            uint256 _diffNowEndLock = _unlockDate.sub(block.timestamp);
            uint256 _multiplicator = _diffNowEndLock.mul(_precision).div(maxLock);
            uint256 _remainingPower = _lockAmount.mul(_multiplicator).div(_precision); 
            _votingBalance = _votingBalance.add(_remainingPower);       
        }
        return _votingBalance;
    }

}