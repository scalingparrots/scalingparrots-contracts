// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BaseOraclePriceConsumer {

    AggregatorV3Interface internal _priceFeed;


    constructor(address _feeOracle) {
        _priceFeed = AggregatorV3Interface(_feeOracle);
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