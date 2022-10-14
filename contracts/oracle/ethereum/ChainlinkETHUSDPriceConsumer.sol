// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "../BaseOraclePriceConsumer.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkETHUSDPriceConsumer is BaseOraclePriceConsumer {
    address _oracleFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    constructor() BaseOraclePriceConsumer(_oracleFeed) {
        AggregatorV3Interface(_oracleFeed);
    }
}
