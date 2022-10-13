// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "../BaseSwapper.sol";
import "@uniswap/v2-periphery/contracts/UniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/UniswapV2Factory.sol";

contract UniswapSwapper is BaseSwapper {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    function _swapExactTokensForTokens(
        address router,
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {
        _safeApproveHelper(startToken, router, balance);
        UniswapV2Router02(router).swapExactTokensForTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapExactETHForTokens(
        address router,
        uint256 balance,
        address[] memory path
    ) internal {
        UniswapV2Router02(router).swapExactETHForTokens{value: balance}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapExactTokensForETH(
        address router,
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {
        _safeApproveHelper(startToken, router, balance);
        UniswapV2Router02(router).swapExactTokensForETH(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _getPair(
        address router,
        address token0,
        address token1
    ) internal view returns (address) {
        address factory = UniswapV2Router02(router).factory();
        return IUniswapV2Factory(factory).getPair(token0, token1);
    }

    /// @notice Add liquidity to uniswap for specified token pair, utilizing the maximum balance possible
    function _addMaxLiquidity(
        address router,
        address token0,
        address token1
    ) internal {
        uint256 _token0Balance =
        IERC20Upgradeable(token0).balanceOf(address(this));
        uint256 _token1Balance =
        IERC20Upgradeable(token1).balanceOf(address(this));

        _safeApproveHelper(token0, router, _token0Balance);
        _safeApproveHelper(token1, router, _token1Balance);

        UniswapV2Router02(router).addLiquidity(
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

    function _addMaxLiquidityEth(address router, address token0) internal {
        // FIXME
        uint256 _token0Balance =
        IERC20Upgradeable(token0).balanceOf(address(this));
        //uint256 _ethBalance = address(this).balance;

        _safeApproveHelper(token0, router, _token0Balance);
        UniswapV2Router02(router).addLiquidityETH{value: address(this).balance}(
            token0,
            _token0Balance,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
}