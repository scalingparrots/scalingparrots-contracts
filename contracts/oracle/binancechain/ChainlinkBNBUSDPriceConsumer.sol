// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "../BaseOraclePriceConsumer.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkETHUSDPriceConsumer is BaseOraclePriceConsumer {
    address _oracleFeed = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    constructor() BaseOraclePriceConsumer(_oracleFeed) {
        AggregatorV3Interface(_oracleFeed);
    }

}