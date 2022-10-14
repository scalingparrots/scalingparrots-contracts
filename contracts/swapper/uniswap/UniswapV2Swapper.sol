// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../BaseSwapper.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Factory.sol";

contract UniswapV2Swapper is BaseSwapper {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    constructor(address _router) BaseSwapper(_router) {
        router = _router;
    }

    function _swapExactTokensForTokens(uint256 balance, address[] memory path)
        internal
    {
        IUniswapV2Router02(router).swapExactTokensForTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapExactETHForTokens(uint256 balance, address[] memory path)
        internal
    {
        IUniswapV2Router02(router).swapExactETHForTokens{value: balance}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapExactTokensForETH(uint256 balance, address[] memory path)
        internal
    {
        IUniswapV2Router02(router).swapExactTokensForETH(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _getPair(address token0, address token1)
        internal
        view
        returns (address)
    {
        address factory = IUniswapV2Router02(router).factory();
        return IUniswapV2Factory(factory).getPair(token0, token1);
    }

    /// @notice Add liquidity to uniswap for specified token pair, utilizing the maximum balance possible
    function _addMaxLiquidity(address token0, address token1) internal {
        uint256 _token0Balance = IERC20(token0).balanceOf(address(this));
        uint256 _token1Balance = IERC20(token1).balanceOf(address(this));

        IUniswapV2Router02(router).addLiquidity(
            token0,
            token1,
            _token0Balance,
            _token1Balance,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function _addMaxLiquidityEth(address token0) internal {
        // FIXME
        uint256 _token0Balance = IERC20(token0).balanceOf(address(this));
        //uint256 _ethBalance = address(this).balance;

        IUniswapV2Router02(router).addLiquidityETH{
            value: address(this).balance
        }(token0, _token0Balance, 0, 0, address(this), block.timestamp);
    }
}
