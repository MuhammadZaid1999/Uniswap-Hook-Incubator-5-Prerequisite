/*
Examples of minting new position, collecting fees, increasing and decreasing liquidity.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

interface INonfungiblePositionManager {
      struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (uint128 liquidity, uint256 amount0, uint256 amount1);

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);
}

contract UniswapV3Liquidity is IERC721Receiver {
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 private constant dai = IERC20(DAI);
    IWETH private constant weth = IWETH(WETH);

    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = -MIN_TICK;
    int24 private constant TICK_SPACING = 60;

    INonfungiblePositionManager public nonfungiblePositionManager =
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function mintNewPosition(uint256 amount0ToAdd, uint256 amount1ToAdd)
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        dai.transferFrom(msg.sender, address(this), amount0ToAdd);
        weth.transferFrom(msg.sender, address(this), amount1ToAdd);

        dai.approve(address(nonfungiblePositionManager), amount0ToAdd);
        weth.approve(address(nonfungiblePositionManager), amount1ToAdd);

        INonfungiblePositionManager.MintParams memory params =
        INonfungiblePositionManager.MintParams({
            token0: DAI,
            token1: WETH,
            fee: 3000,
            tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0ToAdd,
            amount1Desired: amount1ToAdd,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (tokenId, liquidity, amount0, amount1) =
            nonfungiblePositionManager.mint(params);

        if (amount0 < amount0ToAdd) {
            dai.approve(address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToAdd - amount0;
            dai.transfer(msg.sender, refund0);
        }
        if (amount1 < amount1ToAdd) {
            weth.approve(address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToAdd - amount1;
            weth.transfer(msg.sender, refund1);
        }
    }

    function collectAllFees(uint256 tokenId)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.CollectParams memory params =
        INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);
    }

    function increaseLiquidityCurrentRange(
        uint256 tokenId,
        uint256 amount0ToAdd,
        uint256 amount1ToAdd
    ) external returns (uint128 liquidity, uint256 amount0, uint256 amount1) {
        dai.transferFrom(msg.sender, address(this), amount0ToAdd);
        weth.transferFrom(msg.sender, address(this), amount1ToAdd);

        dai.approve(address(nonfungiblePositionManager), amount0ToAdd);
        weth.approve(address(nonfungiblePositionManager), amount1ToAdd);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params =
        INonfungiblePositionManager.IncreaseLiquidityParams({
            tokenId: tokenId,
            amount0Desired: amount0ToAdd,
            amount1Desired: amount1ToAdd,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (liquidity, amount0, amount1) =
            nonfungiblePositionManager.increaseLiquidity(params);

        if (amount0 < amount0ToAdd) {
            dai.approve(address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToAdd - amount0;
            dai.transfer(msg.sender, refund0);
        }
        if (amount1 < amount1ToAdd) {
            weth.approve(address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToAdd - amount1;
            weth.transfer(msg.sender, refund1);
        }  
    }

    function decreaseLiquidityCurrentRange(uint256 tokenId, uint128 liquidity)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params =
        INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: liquidity,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (amount0, amount1) =
            nonfungiblePositionManager.decreaseLiquidity(params);

        nonfungiblePositionManager.collect(INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: msg.sender,
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        }));
    }

    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) TokenToToken ------------- //

    function mintNewPositionTokenToToken(address token0ToAdd, address token1ToAdd, uint256 amount0ToAdd, uint256 amount1ToAdd, uint24 fee)
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        IERC20 token0 = IERC20(token0ToAdd);
        IERC20 token1 = IERC20(token1ToAdd);

        token0.transferFrom(msg.sender, address(this), amount0ToAdd);
        token1.transferFrom(msg.sender, address(this), amount1ToAdd);

        token0.approve(address(nonfungiblePositionManager), amount0ToAdd);
        token1.approve(address(nonfungiblePositionManager), amount1ToAdd);

        INonfungiblePositionManager.MintParams memory params =
        INonfungiblePositionManager.MintParams({
            token0: token0ToAdd,
            token1: token1ToAdd,
            fee: fee,
            tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0ToAdd,
            amount1Desired: amount1ToAdd,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (tokenId, liquidity, amount0, amount1) =
            nonfungiblePositionManager.mint(params);

        if (amount0 < amount0ToAdd) {
            token0.approve(address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToAdd - amount0;
            token0.transfer(msg.sender, refund0);
        }
        if (amount1 < amount1ToAdd) {
            token1.approve(address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToAdd - amount1;
            token1.transfer(msg.sender, refund1);
        }
    }

    function collectAllFeesTokenToToken(uint256 tokenId, address feeAddress)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.CollectParams memory params =
        INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: feeAddress,
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);
    }

    function increaseLiquidityCurrentRangeTokenToToken(
        uint256 tokenId,
        address token0ToAdd,
        address token1ToAdd,
        uint256 amount0ToAdd,
        uint256 amount1ToAdd
    ) external returns (uint128 liquidity, uint256 amount0, uint256 amount1) {
        IERC20 token0 = IERC20(token0ToAdd);
        IERC20 token1 = IERC20(token1ToAdd);

        token0.transferFrom(msg.sender, address(this), amount0ToAdd);
        token1.transferFrom(msg.sender, address(this), amount1ToAdd);

        token0.approve(address(nonfungiblePositionManager), amount0ToAdd);
        token1.approve(address(nonfungiblePositionManager), amount1ToAdd);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params =
        INonfungiblePositionManager.IncreaseLiquidityParams({
            tokenId: tokenId,
            amount0Desired: amount0ToAdd,
            amount1Desired: amount1ToAdd,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (liquidity, amount0, amount1) =
            nonfungiblePositionManager.increaseLiquidity(params);

        if (amount0 < amount0ToAdd) {
            token0.approve(address(nonfungiblePositionManager), 0);
            uint256 refund0 = amount0ToAdd - amount0;
            token0.transfer(msg.sender, refund0);
        }
        if (amount1 < amount1ToAdd) {
            token1.approve(address(nonfungiblePositionManager), 0);
            uint256 refund1 = amount1ToAdd - amount1;
            token1.transfer(msg.sender, refund1);
        }  
    }

    function decreaseLiquidityCurrentRangeTokenToToken(uint256 tokenId, uint128 liquidity)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params =
        INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: liquidity,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (amount0, amount1) =
            nonfungiblePositionManager.decreaseLiquidity(params);
    }

}




/*
Test with Foundry
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {UniswapV3Liquidity, IWETH, IERC20} from "../src/Counter.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract UniswapV3LiquidityTest is Test {
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant usdc = IERC20(USDC);

    IERC721 private constant erc721 = IERC721(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    address private constant DAI_WHALE =
        0xe81D6f03028107A20DBc83176DA82aE8099E9C42;

    UniswapV3Liquidity private uni = new UniswapV3Liquidity();

    function setUp() public {
        vm.prank(DAI_WHALE);
        dai.transfer(address(this), 20 * 1e18);

        weth.deposit{value: 2 * 1e18}();

        dai.approve(address(uni), 20 * 1e18);
        weth.approve(address(uni), 2 * 1e18);
    }

    function testLiquidity() public {
        // Track total liquidity
        uint128 liquidity;

        // Mint new position
        uint256 daiAmount = 10 * 1e18;
        uint256 wethAmount = 1e18;

        (
            uint256 tokenId,
            uint128 liquidityDelta,
            uint256 amount0,
            uint256 amount1
        ) = uni.mintNewPosition(daiAmount, wethAmount);
        liquidity += liquidityDelta;

        console2.log("--- Mint new position ---");
        console2.log("token id", tokenId);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("LP ERC721 Balance", erc721.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", erc721.ownerOf(tokenId) == address(uni));

        // Collect fees
        (uint256 fee0, uint256 fee1) = uni.collectAllFees(tokenId);

        console2.log("--- Collect fees ---");
        console2.log("fee 0", fee0);
        console2.log("fee 1", fee1);

        // Increase liquidity
        uint256 daiAmountToAdd = 5 * 1e18;
        uint256 wethAmountToAdd = 0.5 * 1e18;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRange(
            tokenId, daiAmountToAdd, wethAmountToAdd
        );
        liquidity += liquidityDelta;

        console2.log("--- Increase liquidity ---");
        console2.log("liquidity delta", liquidityDelta);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);

        // Decrease liquidity
        console2.log("dai balance before", dai.balanceOf(address(this)));
        console2.log("weth balance before", weth.balanceOf(address(this)));
        (amount0, amount1) =
            uni.decreaseLiquidityCurrentRange(tokenId, liquidity);
        console2.log("--- Decrease liquidity ---");
        console2.log("weth balance", weth.balanceOf(address(this)));
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("dai balance after", dai.balanceOf(address(this)));
        console2.log("weth balance after", weth.balanceOf(address(this)));
    }

    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) TestLiquidityTokenToToken ------------- //
  
    function testLiquidityTokenToToken() public {
        deal(USDC, address(this), 10 * 1e6);
        usdc.approve(address(uni), 10 * 1e6);

        // Track total liquidity
        uint128 liquidity;

        // Mint new position
        uint256 daiAmount = 10 * 1e18;
        uint256 usdcAmount = 5 * 1e6;

        (
            uint256 tokenId,
            uint128 liquidityDelta,
            uint256 amount0,
            uint256 amount1
        ) = uni.mintNewPositionTokenToToken(DAI, USDC, daiAmount, usdcAmount, 100);
        liquidity += liquidityDelta;

        console2.log("--- Mint new position ---");
        console2.log("token id", tokenId);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("LP ERC721 Balance", erc721.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", erc721.ownerOf(tokenId) == address(uni));
        console2.log("DAI Balance after Mint New Position", dai.balanceOf(address(this)));
        console2.log("USDC Balance after Mint New Position", usdc.balanceOf(address(this)));

        // Increase liquidity
        uint256 daiAmountToAdd = 5 * 1e18;
        uint256 usdcAmountToAdd = 2.5 * 1e6;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRangeTokenToToken(
            tokenId, DAI, USDC, daiAmountToAdd, usdcAmountToAdd
        );
        liquidity += liquidityDelta;

        console2.log("--- Increase liquidity ---");
        console2.log("liquidity delta", liquidityDelta);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("DAI Balance after Increase liquidity", dai.balanceOf(address(this)));
        console2.log("USDC Balance after Increase liquidity", usdc.balanceOf(address(this)));

        // Decrease liquidity
        console2.log("--- Decrease liquidity ---");
        (amount0, amount1) =
            uni.decreaseLiquidityCurrentRangeTokenToToken(tokenId, liquidity);
        console2.log("usdc balance", weth.balanceOf(address(this)));
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);

        // Collect fees after decrease liquidity
        (uint256 fee0, uint256 fee1) = uni.collectAllFeesTokenToToken(tokenId, address(this));
        console2.log("--- Collect fees ---");
        console2.log("fee 0", fee0);
        console2.log("fee 1", fee1);
        console2.log("DAI Balance after Decrease liquidity", dai.balanceOf(address(this)));
        console2.log("USDC Balance after DEcrease liquidity", usdc.balanceOf(address(this)));
    }

}