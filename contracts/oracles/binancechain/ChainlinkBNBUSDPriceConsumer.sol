// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkBNBUSDPriceConsumer {

    AggregatorV3Interface internal _priceFeed;


    constructor() {
        _priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
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