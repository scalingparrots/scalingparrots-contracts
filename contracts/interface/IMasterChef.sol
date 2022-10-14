// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IMasterChef {
    function emergencyWithdraw(uint256 _pid) external;

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function pending(uint256 _pid, address _user)
        external
        view
        returns (uint256, uint256);

    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (uint256, uint256);
}
