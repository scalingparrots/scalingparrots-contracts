// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AutoVesting is Ownable {
    using SafeERC20 for IERC20;

    event Deposit(uint _amount, uint _days, uint indexed _id, address indexed _owner);
    event Withdraw(uint indexedId, address indexed _owner);

    struct Lock {
        uint start;
        uint end;
        uint amount;
        uint period;
        uint reward;
        bool claimed;
    }

    IERC20 public baseToken;
    Lock[] public locks;

    uint public availableRewards;
    uint public startBlock;
    uint public rewardsBase; 
    uint public rewardsAfterOneMonth;
    uint public rewardsAfterThreeMonths;
    uint public rewardsAfterSixMonths;
    uint public rewardsAfterOneYear;

    uint public constant MAX_FEE = 1000;
    uint public emergencyWithdrawPenalty = 50; // 50 means 5%
    address public penaltyAddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint[]) public locksByAddress;
    mapping (uint => mapping (address => bool)) public isLockOfAddress;
    mapping (address => uint) public depositedCoc;

    /**
     * @notice Constructor
     * @param _baseToken TOKEN address
     * @param _startBlock Block from which rewards will be distributed
     * @param _baseReward How many TOKEN has to be rewarded for each deposited TOKEN per day if deposit lasts 
            less than a month
     * @param _rewardsAfterOneMonth How many TOKEN has to be rewarded for each deposited TOKEN per day if deposit 
            lasts less than three months
     * @param _rewardsAfterThreeMonths How many TOKEN has to be rewarded for each deposited TOKEN per day if deposit 
            lasts less than six months
     * @param _rewardsAfterSixMonths How many TOKEN has to be rewarded for each deposited TOKEN per day if deposit
            lasts less than a year
     * @param _rewardsAfterOneYear How many TOKEN has to be rewarded for each deposited TOKEN per day if deposit 
            lasts more than a year
     */
    constructor (IERC20 _baseToken, uint _startBlock, uint _baseReward, uint _rewardsAfterOneMonth, 
        uint _rewardsAfterThreeMonths, uint _rewardsAfterSixMonths, uint _rewardsAfterOneYear) {

        baseToken = IERC20(_baseToken);
        startBlock = _startBlock;
        rewardsBase = _baseReward;
        rewardsAfterOneMonth = _rewardsAfterOneMonth;
        rewardsAfterThreeMonths = _rewardsAfterThreeMonths;
        rewardsAfterSixMonths = _rewardsAfterSixMonths;
        rewardsAfterOneYear = _rewardsAfterOneYear;
    }

    /**
     * @notice Add new lock 
     * @param _amount Amount of TOKEN to lock
     * @param _days Lock duration in days
     */
    function deposit(uint _amount, uint _days) external {
        require(block.number >= startBlock, "COCVEsting: cannot deposit yet");
        require (_days > 0, "COCVesting: cannot lock tokens for zero days");

        // Lock tokens
        SafeERC20.safeTransferFrom(baseToken, msg.sender, address(this), _amount);
        depositedCoc[msg.sender] += _amount;

        // Compute rewards
        uint lockReward = _computeRewards(_days);

        // Create lock
        uint start = block.timestamp;
        uint end = block.timestamp + _days * (1 days);
        Lock memory lock = Lock({
            start: start, 
            end: end, 
            amount: _amount, 
            period: _days, 
            reward: lockReward,
            claimed: false
        });

        // Add lock to locks list
        locks.push(lock);

        // Find lock id
        uint lockId = locks.length - 1;

        // Assign lock to user
        uint[] storage info = locksByAddress[msg.sender];
        info.push(lockId);

        isLockOfAddress[lockId][msg.sender] = true;

        // Emit Deposit event
        emit Deposit(_amount, _days, lockId, msg.sender);
    }

    /**
     * @notice Add new lock 
     * @param _lockId Lock id
     */
    function withdraw(uint _lockId) external {
        require (isLockOfAddress[_lockId][msg.sender], "COCVesting: not your lock");

        // Retrieve lock
        Lock storage lock = locks[_lockId];
        require (block.timestamp > lock.end, "COCVesting: TOKEN still locked");
        require (! lock.claimed, "COCVesting: lock already claimed");

        // Compute rewards
        uint rewards = lock.reward * lock.amount * lock.period / 1e18;

        if (rewards > availableRewards) {
            rewards = availableRewards;
        }

        // Withdraw TOKEN
        uint amount = lock.amount + rewards;
        SafeERC20.safeTransfer(baseToken, msg.sender, amount);
        depositedCoc[msg.sender] -= lock.amount;

        // Update lock claimed
        lock.claimed = true;

        // Update available rewards
        availableRewards -= rewards;

        // Emit Withdraw event
        emit Withdraw(_lockId, msg.sender);
    }

    /**
     * @notice Withdraw TOKEN without caring about rewards
     */
    function emergencyWithdraw() external {
        uint deposited = depositedCoc[msg.sender];
        require (deposited > 0, "COCVesting: nothing to withdraw");

        // Compute penalty
        uint penalty = deposited * emergencyWithdrawPenalty / 1000;

        // Withdraw deposited TOKEN
        uint amount = deposited - penalty;
        SafeERC20.safeTransfer(baseToken, msg.sender, amount);

        // Burn penalty
        SafeERC20.safeTransfer(baseToken, penaltyAddress, penalty);

        // Reset user info
        depositedCoc[msg.sender] = 0;

        // Emulate claims for all user locks
        uint[] storage ids = locksByAddress[msg.sender];
        for (uint i = 0; i < ids.length; i++) {
            uint currentId = ids[i];
            locks[currentId].claimed = true;
        }
    }

    /**
     * @notice Estimate rewards of a lock
     * @param _amount Amount of TOKEN to lock
     * @param _days Days to lock TOKEN
     */
    function estimateRewards(uint _amount, uint _days) external view returns (uint rewards) {
        rewards = _computeRewards(_days) * _amount * _days;
    }

    /**
     * @notice Add TOKEN to the rewards reserve
     * @param _amount Amount of TOKEN to add in the rewards reserve
     */
    function fund(uint _amount) external {
        // Take TOKEN from caller
        SafeERC20.safeTransferFrom(baseToken, msg.sender, address(this), _amount);

        // Update available rewards
        availableRewards += _amount;
    }

    /**
     * @notice Return array with all locks id of an address
     * @param _address The address we are interested in
     */
    function getLocksIdByAddress(address _address) external view returns (uint[] memory locksId) {
        locksId = locksByAddress[_address];
    }

    // PRIVILEGED FUNCTIONS
    /**
     * @notice Update TOKEN base reward
     * @param _reward TOKEN base reward
     */
    function setBaseReward(uint _reward) external onlyOwner {
        rewardsBase = _reward;
    }

    /**
     * @notice Update TOKEN rewards after one month
     * @param _reward TOKEN reward after one month
     */
    function setRewardsAfterOneMonth(uint _reward) external onlyOwner {
        rewardsAfterOneMonth = _reward;
    }

    /**
     * @notice Update TOKEN rewards after three months
     * @param _reward TOKEN reward after three months
     */
    function setRewardsAfterThreeMonths(uint _reward) external onlyOwner {
        rewardsAfterThreeMonths = _reward;
    }

    /**
     * @notice Update TOKEN rewards after six months
     * @param _reward TOKEN reward after six months
     */
    function setRewardsAfterSixMonths(uint _reward) external onlyOwner {
        rewardsAfterSixMonths = _reward;
    }

    /**
     * @notice Update TOKEN rewards after one year
     * @param _reward TOKEN reward after one year
     */
    function setRewardsAfterOneYear(uint _reward) external onlyOwner {
        rewardsAfterOneYear = _reward;
    }

    /**
     * @notice Withdraw rewards
     * @param _amount Amount of rewards to withdraw
     * @dev Only callable by the owner
     */
    function emergencyWithdrawRewards(uint _amount) external onlyOwner {
        require (_amount <= availableRewards, "COCVesting: not enough rewards");
        
        availableRewards -= _amount;
        SafeERC20.safeTransfer(baseToken, msg.sender, _amount);
    }

    /**
     * @notice Change TOKEN address
     * @param _address New TOKEN address
     */
    function changeCoc(address _address) external onlyOwner {
        baseToken = IERC20(_address);
    }

    /**
     * @notice Change burn address
     * @param _address New burn address
     */
    function changePenaltyAddress(address _address) external onlyOwner {
        require(penaltyAddress != address(0), "COCVesting: cannot set penalty address as 0");

        penaltyAddress = _address;
    }

    /**
     * @notice Change penalty fee
     * @param _fee New penalty fee
     * @dev fee is computer over 1000, ie 50 means 5% fee
     */
    function changePenaltyFee(uint _fee) external onlyOwner {
        require(_fee <= MAX_FEE, "COCVesting: invalid fee");

        emergencyWithdrawPenalty = _fee;
    }

    // INTERNAL FUNCTIONS
    function _computeRewards(uint _days) internal view returns (uint lockReward) {
        // 1 year or more lock
        if (_days >= 365) {
            lockReward = rewardsAfterOneYear;
        }
        // 6 months to 1 year lock
        else if (_days >= 180) {
            lockReward = rewardsAfterSixMonths;
        }
        // 3 months to 6 months lock
        else if (_days >= 90) {
            lockReward = rewardsAfterThreeMonths;
        }
        // 1 month to 3 months lock
        else if (_days >= 30) {
            lockReward = rewardsAfterOneMonth;
        }
        // less than a month
        else {
            lockReward = rewardsBase;
        }
    }
}