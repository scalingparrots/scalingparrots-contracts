// SPDX-License-Identifier: ISC

pragma solidity ^0.8.9;

interface IStrategy {
    function want() external view returns (address);
    function deposit() external;
    function withdrawOther(address) external returns (uint256 balance);
    function withdraw(uint256) external;
    function withdrawAll() external returns (uint256);
    function balanceOf() external view returns (uint256);
    function getName() external pure returns (string memory);
    function setStrategist(address _strategist) external;
    function setWithdrawalFee(uint256 _withdrawalFee) external;
    function setPerformanceFeeStrategist(uint256 _performanceFeeStrategist) external;
    function setPerformanceFeeGovernance(uint256 _performanceFeeGovernance) external;
    function setGovernance(address _governance) external;
    function setController(address _controller) external;
    function tend() external;
    function harvest() external;
}