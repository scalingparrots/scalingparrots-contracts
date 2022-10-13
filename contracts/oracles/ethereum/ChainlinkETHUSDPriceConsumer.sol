// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkETHUSDPriceConsumer {

    AggregatorV3Interface internal _priceFeed;


    constructor() {
        _priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            , 
            int price,
            ,
            ,
            
        ) = _priceFeed.latestRoundData();
        return price;
    }

    function getDecimals() public view returns (uint8) {
        return _priceFeed.decimals();
    }
}