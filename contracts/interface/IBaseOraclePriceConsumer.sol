// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IBaseOraclePriceConsumer {
    function getDecimals() external view returns(uint8);
    function getLatestPrice() external view returns(int);
}
