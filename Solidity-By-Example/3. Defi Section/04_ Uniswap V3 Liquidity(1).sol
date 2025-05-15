/*
Examples of minting new position, collecting fees, increasing and decreasing liquidity.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {console2} from "forge-std/Test.sol";

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

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );    
}

contract UniswapV3Liquidity is IERC721Receiver {
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 private constant dai = IERC20(DAI);
    IWETH private constant weth = IWETH(WETH);

    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = -MIN_TICK;
    int24 private constant TICK_SPACING = 60;

    receive() external payable {}

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

    function mintNewPositionTokenToToken(
        address tokenAInput,
        address tokenBInput,
        uint256 amountAInput,
        uint256 amountBInput,
        uint24 fee
    )
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        IERC20 tokenA = IERC20(tokenAInput);
        IERC20 tokenB = IERC20(tokenBInput);

        tokenA.transferFrom(msg.sender, address(this), amountAInput);
        tokenB.transferFrom(msg.sender, address(this), amountBInput);

        tokenA.approve(address(nonfungiblePositionManager), amountAInput);
        tokenB.approve(address(nonfungiblePositionManager), amountBInput);

        (address token0, address token1, uint256 amount0Desired, uint256 amount1Desired) =
            tokenAInput < tokenBInput
                ? (tokenAInput, tokenBInput, amountAInput, amountBInput)
                : (tokenBInput, tokenAInput, amountBInput, amountAInput);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Refund unused token amounts
        if (amount0 < amount0Desired) {
            IERC20(token0).approve(address(nonfungiblePositionManager), 0);
            IERC20(token0).transfer(msg.sender, amount0Desired - amount0);
        }

        if (amount1 < amount1Desired) {
            IERC20(token1).approve(address(nonfungiblePositionManager), 0);
            IERC20(token1).transfer(msg.sender, amount1Desired - amount1);
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
        address tokenAInput,
        address tokenBInput,
        uint256 amountAInput,
        uint256 amountBInput
    )
        external
        returns (uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        IERC20 tokenA = IERC20(tokenAInput);
        IERC20 tokenB = IERC20(tokenBInput);

        tokenA.transferFrom(msg.sender, address(this), amountAInput);
        tokenB.transferFrom(msg.sender, address(this), amountBInput);

        tokenA.approve(address(nonfungiblePositionManager), amountAInput);
        tokenB.approve(address(nonfungiblePositionManager), amountBInput);

        (address token0, address token1, uint256 amount0Desired, uint256 amount1Desired) =
            tokenAInput < tokenBInput
                ? (tokenAInput, tokenBInput, amountAInput, amountBInput)
                : (tokenBInput, tokenAInput, amountBInput, amountAInput);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager.IncreaseLiquidityParams({
            tokenId: tokenId,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);

        // Refund unused tokens
        if (amount0 < amount0Desired) {
            IERC20(token0).approve(address(nonfungiblePositionManager), 0);
            IERC20(token0).transfer(msg.sender, amount0Desired - amount0);
        }

        if (amount1 < amount1Desired) {
            IERC20(token1).approve(address(nonfungiblePositionManager), 0);
            IERC20(token1).transfer(msg.sender, amount1Desired - amount1);
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

    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) EthToToken ------------- //
    // Directly Eth transfer cannot return remaining Eth from NonfungiblePositionManager Contract

    function mintNewPositionEthToToken(
        address tokenToAdd,
        uint256 tokenAmountToAdd,
        uint256 ethAmountToAdd,
        uint24 fee
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(msg.value >= ethAmountToAdd, "Incorrect ETH sent");

        IERC20 token = IERC20(tokenToAdd);

        // Transfer ERC20 from user
        token.transferFrom(msg.sender, address(this), tokenAmountToAdd);

        // Approve NonfungiblePositionManager
        token.approve(address(nonfungiblePositionManager), tokenAmountToAdd);

        // Determine token order
        (address token0, address token1, uint256 amount0Desired, uint256 amount1Desired) =
            WETH < tokenToAdd
                ? (WETH, tokenToAdd, ethAmountToAdd, tokenAmountToAdd)
                : (tokenToAdd, WETH, tokenAmountToAdd, ethAmountToAdd);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        // Call mint with ETH value
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint{value: ethAmountToAdd}(params);

        // Refund unused ETH
        uint256 ethUsed = WETH == token0 ? amount0 : amount1;
        if (ethUsed < ethAmountToAdd) {
            console2.log("address uni eth balance", address(this).balance);
            console2.log("address nonfungiblePositionManager eth balance", address(nonfungiblePositionManager).balance);
            console2.log("address uni weth balance", weth.balanceOf(address(this)));
            console2.log("address nonfungiblePositionManager weth balance", weth.balanceOf(address(nonfungiblePositionManager)));
            // IWETH(WETH).withdraw(ethAmountToAdd - ethUsed);
            // payable(msg.sender).transfer(ethAmountToAdd - ethUsed);
        }

        // Refund unused token
        uint256 tokenUsed = tokenToAdd == token0 ? amount0 : amount1;
        if (tokenUsed < tokenAmountToAdd) {
            uint256 refund1 = tokenAmountToAdd - tokenUsed;
            token.approve(address(nonfungiblePositionManager), 0);
            token.transfer(msg.sender, refund1);
        }
    }

    function collectAllFeesEthToToken(uint256 tokenId, address feeRecipient)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: feeRecipient,
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);

        ( , , address token0, address token1, , , , , , , , ) = nonfungiblePositionManager.positions(tokenId);

        if (token0 == address(WETH)) {
            // payable(msg.sender).transfer(amount0);
        } else {
            // payable(msg.sender).transfer(amount1);
        }
    }

    function increaseLiquidityCurrentRangeEthToToken(
        uint256 tokenId,
        address tokenToAdd,
        uint256 tokenAmountToAdd,
        uint256 ethAmountToAdd
    ) external payable returns (uint128 liquidity, uint256 amount0, uint256 amount1) {

        require(msg.value >= ethAmountToAdd, "Incorrect ETH sent");

      
        IERC20 token = IERC20(tokenToAdd);
        token.transferFrom(msg.sender, address(this), tokenAmountToAdd);
        token.approve(address(nonfungiblePositionManager), tokenAmountToAdd);

        // Determine token order
        (address token0, address token1, uint256 amount0Desired, uint256 amount1Desired) =
            address(WETH) < tokenToAdd
                ? (address(WETH), tokenToAdd, ethAmountToAdd, tokenAmountToAdd)
                : (tokenToAdd, address(WETH), tokenAmountToAdd, ethAmountToAdd);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params =
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity{value: ethAmountToAdd}(params);

         // Refund unused ETH
        uint256 ethUsed = address(WETH) == token0 ? amount0 : amount1;
        if (ethAmountToAdd > ethUsed) {
            uint256 refund = ethAmountToAdd - ethUsed;
            
            console2.log("increase liquidity address uni eth balance", address(this).balance);
            console2.log("increase liquidity address nonfungiblePositionManager eth balance", address(nonfungiblePositionManager).balance);
            console2.log("increase liquidity address uni weth balance", weth.balanceOf(address(this)));
            console2.log("increase liquidity address nonfungiblePositionManager weth balance", weth.balanceOf(address(nonfungiblePositionManager)));
            // weth.withdraw(ethAmountToAdd - ethUsed);
            // payable(msg.sender).transfer(refund);
        }

        // Refund unused token
        uint256 tokenUsed = tokenToAdd == token0 ? amount0 : amount1;
        if (tokenAmountToAdd > tokenUsed) {
            token.approve(address(nonfungiblePositionManager), 0);
            token.transfer(msg.sender, tokenAmountToAdd - tokenUsed);
        }
    }

    function decreaseLiquidityCurrentRangeEthToToken(uint256 tokenId, uint128 liquidity)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: liquidity,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
    }

    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) EthToToken ------------- //
 
    function mintNewPositionEthToToken1(
        address tokenToAdd,
        uint256 tokenAmountToAdd,
        uint256 ethAmountToAdd,
        uint24 fee
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(msg.value >= ethAmountToAdd, "Incorrect ETH sent");

        weth.deposit{value: ethAmountToAdd}();

        IERC20 token = IERC20(tokenToAdd);
        // Transfer ERC20 from user
        token.transferFrom(msg.sender, address(this), tokenAmountToAdd);

        // Approve NonfungiblePositionManager
        weth.approve(address(nonfungiblePositionManager), ethAmountToAdd);
        token.approve(address(nonfungiblePositionManager), tokenAmountToAdd);

        // Determine token order
        (address token0, address token1, uint256 amount0Desired, uint256 amount1Desired) =
            address(WETH) < tokenToAdd
                ? (address(WETH), tokenToAdd, ethAmountToAdd, tokenAmountToAdd)
                : (tokenToAdd, address(WETH), tokenAmountToAdd, ethAmountToAdd);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        // Call mint with ETH value
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Refund unused ETH
        uint256 ethUsed = address(WETH) == token0 ? amount0 : amount1;
        if (ethAmountToAdd > ethUsed) {
            uint256 refund0 = ethAmountToAdd - ethUsed;
            weth.withdraw(refund0);
            payable(msg.sender).transfer(refund0);
        }

        // Refund unused token
        uint256 tokenUsed = tokenToAdd == token0 ? amount0 : amount1;
        if (tokenAmountToAdd > tokenUsed) {
            token.approve(address(nonfungiblePositionManager), 0);
            token.transfer(msg.sender, tokenAmountToAdd - tokenUsed);
        }
    }

    function collectAllFeesEthToToken1(uint256 tokenId, address feeRecipient)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);

        ( , , address token0, address token1, , , , , , , , ) = nonfungiblePositionManager.positions(tokenId);

        uint256 ethAmount =  token0 == address(WETH) ? amount0 : amount1;
        weth.withdraw(ethAmount);
        payable(msg.sender).transfer(ethAmount);

        uint256 tokenAmount =  token0 != address(WETH) ? amount0 : amount1;
        IERC20(token0).transfer(msg.sender, tokenAmount);
    }

    function increaseLiquidityCurrentRangeEthToToken1(
        uint256 tokenId,
        address tokenToAdd,
        uint256 tokenAmountToAdd,
        uint256 ethAmountToAdd
    ) external payable returns (uint128 liquidity, uint256 amount0, uint256 amount1) {

        require(msg.value >= ethAmountToAdd, "Incorrect ETH sent");
        weth.deposit{value: ethAmountToAdd}();

        IERC20 token = IERC20(tokenToAdd);
        token.transferFrom(msg.sender, address(this), tokenAmountToAdd);
        
        token.approve(address(nonfungiblePositionManager), tokenAmountToAdd);
        weth.approve(address(nonfungiblePositionManager), ethAmountToAdd);

        // Determine token order
        (address token0, address token1, uint256 amount0Desired, uint256 amount1Desired) =
            address(WETH) < tokenToAdd
                ? (address(WETH), tokenToAdd, ethAmountToAdd, tokenAmountToAdd)
                : (tokenToAdd, address(WETH), tokenAmountToAdd, ethAmountToAdd);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params =
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);

         // Refund unused ETH
        uint256 ethUsed = address(WETH) == token0 ? amount0 : amount1;
        if (ethAmountToAdd > ethUsed) {
            uint256 refund = ethAmountToAdd - ethUsed;
            weth.withdraw(refund);
            payable(msg.sender).transfer(refund);
        }

        // Refund unused token
        uint256 tokenUsed = tokenToAdd == token0 ? amount0 : amount1;
        if (tokenAmountToAdd > tokenUsed) {
            uint256 refund = tokenAmountToAdd - tokenUsed;
            token.approve(address(nonfungiblePositionManager), 0);
            token.transfer(msg.sender, refund);
        }
    }

    function decreaseLiquidityCurrentRangeEthToToken1(uint256 tokenId, uint128 liquidity)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: liquidity,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });

        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
    }

    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) TokenToEth ------------- //

    function mintNewPositionTokenToEth(
        address tokenToAdd,
        uint256 tokenAmountToAdd,
        uint256 ethAmountToAdd,
        uint24 fee
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(msg.value >= ethAmountToAdd, "Incorrect ETH sent");
        weth.deposit{value: ethAmountToAdd}();

        IERC20 token = IERC20(tokenToAdd);
        token.transferFrom(msg.sender, address(this), tokenAmountToAdd);

        token.approve(address(nonfungiblePositionManager), tokenAmountToAdd);
        weth.approve(address(nonfungiblePositionManager), ethAmountToAdd);

        (address token0, address token1, uint256 amount0Desired, uint256 amount1Desired) =
            tokenToAdd < address(WETH)
                ? (tokenToAdd, address(WETH), tokenAmountToAdd, ethAmountToAdd)
                : (address(WETH), tokenToAdd, ethAmountToAdd, tokenAmountToAdd);

        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: (MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp
        });

        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

        // Refund unused ETH
        uint256 ethUsed = address(WETH) == token0 ? amount0 : amount1;
        if (ethAmountToAdd > ethUsed) {
            uint256 refund = ethAmountToAdd - ethUsed;
            weth.withdraw(refund);
            payable(msg.sender).transfer(refund);
        }

        // Refund unused token
        uint256 tokenUsed = tokenToAdd == token0 ? amount0 : amount1;
        if (tokenAmountToAdd > tokenUsed) {
            token.approve(address(nonfungiblePositionManager), 0);
            token.transfer(msg.sender, tokenAmountToAdd - tokenUsed);
        }
    }

    function collectAllFeesTokenToEth(uint256 tokenId, address recipient)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);

        ( , , address token0, address token1, , , , , , , , ) = nonfungiblePositionManager.positions(tokenId);

        uint256 ethAmount =  token0 == address(WETH) ? amount0 : amount1;
        weth.withdraw(ethAmount);
        payable(msg.sender).transfer(ethAmount);

        uint256 tokenAmount =  token0 != address(WETH) ? amount0 : amount1;
        IERC20(token0).transfer(msg.sender, tokenAmount);
    }

    function increaseLiquidityCurrentRangeTokenToEth(
        uint256 tokenId,
        address tokenToAdd,
        uint256 tokenAmountToAdd,
        uint256 ethAmountToAdd
    )
        external
        payable
        returns (uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        require(msg.value >= ethAmountToAdd, "Incorrect ETH sent");
        weth.deposit{value: ethAmountToAdd}();

        IERC20 token = IERC20(tokenToAdd);
        token.transferFrom(msg.sender, address(this), tokenAmountToAdd);
        
        token.approve(address(nonfungiblePositionManager), tokenAmountToAdd);
        weth.approve(address(nonfungiblePositionManager), ethAmountToAdd);

        INonfungiblePositionManager.IncreaseLiquidityParams memory params =
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: tokenToAdd < address(WETH) ? tokenAmountToAdd : ethAmountToAdd,
                amount1Desired: tokenToAdd < address(WETH) ? ethAmountToAdd : tokenAmountToAdd,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);

        // Refund unused ETH
        uint256 ethUsed = tokenToAdd < address(WETH) ? amount1 : amount0;
        if (ethAmountToAdd > ethUsed) {
            uint256 refund = ethAmountToAdd - ethUsed;
            weth.withdraw(refund);
            payable(msg.sender).transfer(refund);
        }

        // Refund unused token
        uint256 tokenUsed = tokenToAdd < address(WETH) ? amount0 : amount1;
        if (tokenAmountToAdd > tokenUsed) {
            token.approve(address(nonfungiblePositionManager), 0);
            token.transfer(msg.sender, tokenAmountToAdd - tokenUsed);
        }
    }

    function decreaseLiquidityCurrentRangeTokenToEth(uint256 tokenId, uint128 liquidity)
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

        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
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

    IERC721 private constant lpNFT = IERC721(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    receive() external payable {}

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
        console2.log("LP ERC721 Balance", lpNFT.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", lpNFT.ownerOf(tokenId) == address(uni));

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
        console2.log("LP ERC721 Balance", lpNFT.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", lpNFT.ownerOf(tokenId) == address(uni));
        console2.log("DAI Balance after Mint New Position", dai.balanceOf(address(this)));
        console2.log("USDC Balance after Mint New Position", usdc.balanceOf(address(this)));

        // Increase liquidity
        uint256 daiAmountToAdd = 5 * 1e18;
        uint256 usdcAmountToAdd = 2.5 * 1e6;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRangeTokenToToken(
            tokenId, DAI, USDC, daiAmount, usdcAmount
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

    function testLiquidityTokenToToken1() public {
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
        ) = uni.mintNewPositionTokenToToken(USDC, DAI, usdcAmount, daiAmount, 100);
        liquidity += liquidityDelta;

        console2.log("--- Mint new position ---");
        console2.log("token id", tokenId);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("LP ERC721 Balance", lpNFT.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", lpNFT.ownerOf(tokenId) == address(uni));
        console2.log("DAI Balance after Mint New Position", dai.balanceOf(address(this)));
        console2.log("USDC Balance after Mint New Position", usdc.balanceOf(address(this)));

        // Increase liquidity
        uint256 daiAmountToAdd = 5 * 1e18;
        uint256 usdcAmountToAdd = 2.5 * 1e6;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRangeTokenToToken(
            tokenId, USDC, DAI, usdcAmount, daiAmount
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


    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) TestLiquidityEthToToken ------------- //
    // Directly Eth transfer cannot return remaining Eth from NonfungiblePositionManager Contract
  
    function testLiquidityEthToToken() public {
        deal(USDC, address(this), 1000 * 1e6);
        usdc.approve(address(uni), 1000 * 1e6);

        console2.log("ETH Balance before Mint New Position", address(this).balance);
        console2.log("USDC Balance before Mint New Position", usdc.balanceOf(address(this)));
        
        // Track total liquidity
        uint128 liquidity;

        // Mint new position
        uint256 ethAmount = 1 * 1e18;
        uint256 usdcAmount = 500 * 1e6;

        (
            uint256 tokenId,
            uint128 liquidityDelta,
            uint256 amount0,
            uint256 amount1
        ) = uni.mintNewPositionEthToToken{value: ethAmount}(USDC, usdcAmount, ethAmount, 100);
        liquidity += liquidityDelta;

        console2.log("--- Mint new position ---");
        console2.log("token id", tokenId);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("LP ERC721 Balance", lpNFT.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", lpNFT.ownerOf(tokenId) == address(uni));
        console2.log("ETH Balance after Mint New Position", address(this).balance);
        console2.log("USDC Balance after Mint New Position", usdc.balanceOf(address(this)));

        // Increase liquidity
        uint256 ethAmountToAdd = 0.5 * 1e18;
        uint256 usdcAmountToAdd = 250 * 1e6;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRangeEthToToken{value: ethAmountToAdd}(
            tokenId, USDC, usdcAmountToAdd, ethAmountToAdd
        );
        liquidity += liquidityDelta;

        console2.log("--- Increase liquidity ---");
        console2.log("liquidity delta", liquidityDelta);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("ETH Balance after Increase liquidity Position", address(this).balance);
        console2.log("USDC Balance after Increase liquidity Position", usdc.balanceOf(address(this)));

        // Decrease liquidity
        console2.log("--- Decrease liquidity ---");
        (amount0, amount1) =
            uni.decreaseLiquidityCurrentRangeEthToToken(tokenId, liquidity);
        console2.log("usdc balance", weth.balanceOf(address(this)));
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);

        // Collect fees after decrease liquidity
        (uint256 fee0, uint256 fee1) = uni.collectAllFeesEthToToken(tokenId, address(this));
        console2.log("--- Collect fees ---");
        console2.log("fee 0", fee0);
        console2.log("fee 1", fee1);
        console2.log("ETH Balance after Decrease liquidity", address(this).balance);
        console2.log("USDC Balance after Decrease liquidity", usdc.balanceOf(address(this)));
    }

    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) TestLiquidityEthToToken ------------- //
  
    function testLiquidityEthToToken1() public {
        deal(USDC, address(this), 1000 * 1e6);
        usdc.approve(address(uni), 1000 * 1e6);

        console2.log("ETH Balance before Mint New Position", address(this).balance);
        console2.log("USDC Balance before Mint New Position", usdc.balanceOf(address(this)));


        // Track total liquidity
        uint128 liquidity;

        // Mint new position
        uint256 ethAmount = 1 * 1e18;
        uint256 usdcAmount = 500 * 1e6;

        (
            uint256 tokenId,
            uint128 liquidityDelta,
            uint256 amount0,
            uint256 amount1
        ) = uni.mintNewPositionEthToToken1{value: ethAmount}(USDC, usdcAmount, ethAmount, 100);
        liquidity += liquidityDelta;

        console2.log("--- Mint new position ---");
        console2.log("token id", tokenId);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("LP ERC721 Balance", lpNFT.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", lpNFT.ownerOf(tokenId) == address(uni));
        console2.log("ETH Balance after Mint New Position", address(this).balance);
        console2.log("USDC Balance after Mint New Position", usdc.balanceOf(address(this)));

        // Increase liquidity
        uint256 ethAmountToAdd = 0.5 * 1e18;
        uint256 usdcAmountToAdd = 250 * 1e6;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRangeEthToToken1{value: ethAmountToAdd}(
            tokenId, USDC, usdcAmountToAdd, ethAmountToAdd
        );
        liquidity += liquidityDelta;

        console2.log("--- Increase liquidity ---");
        console2.log("liquidity delta", liquidityDelta);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("ETH Balance after Increase Liquidity Position", address(this).balance);
        console2.log("USDC Balance after Increase Liquidity Position", usdc.balanceOf(address(this)));

        // Decrease liquidity
        console2.log("--- Decrease liquidity ---");
        (amount0, amount1) =
            uni.decreaseLiquidityCurrentRangeEthToToken1(tokenId, liquidity);
        console2.log("usdc balance", weth.balanceOf(address(this)));
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);

        // Collect fees after decrease liquidity
        (uint256 fee0, uint256 fee1) = uni.collectAllFeesEthToToken1(tokenId, address(this));
        console2.log("--- Collect fees ---");
        console2.log("fee 0", fee0);
        console2.log("fee 1", fee1);
        console2.log("ETH Balance after Decrease liquidity", address(this).balance);
        console2.log("USDC Balance after Decrease liquidity", usdc.balanceOf(address(this)));
    }

    // ------- (MintNewPosition, CollectAllFees, IncreaseLiquidity, DecreaseLiquidity) TestLiquidityTokenToEth ------------- //
  
    function testLiquidityTokenToEth() public {
        deal(USDC, address(this), 1000 * 1e6);
        usdc.approve(address(uni), 1000 * 1e6);

        console2.log("ETH Balance before Mint New Position", address(this).balance);
        console2.log("USDC Balance before Mint New Position", usdc.balanceOf(address(this)));


        // Track total liquidity
        uint128 liquidity;

        // Mint new position
        uint256 ethAmount = 1 * 1e18;
        uint256 usdcAmount = 500 * 1e6;

        (
            uint256 tokenId,
            uint128 liquidityDelta,
            uint256 amount0,
            uint256 amount1
        ) = uni.mintNewPositionTokenToEth{value: ethAmount}(USDC, usdcAmount, ethAmount, 100);
        liquidity += liquidityDelta;

        console2.log("--- Mint new position ---");
        console2.log("token id", tokenId);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("LP ERC721 Balance", lpNFT.balanceOf(address(uni)));
        console2.log("LP ERC721 Owner", lpNFT.ownerOf(tokenId) == address(uni));
        console2.log("ETH Balance after Mint New Position", address(this).balance);
        console2.log("USDC Balance after Mint New Position", usdc.balanceOf(address(this)));

        // Increase liquidity
        uint256 ethAmountToAdd = 0.5 * 1e18;
        uint256 usdcAmountToAdd = 250 * 1e6;

        (liquidityDelta, amount0, amount1) = uni.increaseLiquidityCurrentRangeTokenToEth{value: ethAmountToAdd}(
            tokenId, USDC, usdcAmountToAdd, ethAmountToAdd
        );
        liquidity += liquidityDelta;

        console2.log("--- Increase liquidity ---");
        console2.log("liquidity delta", liquidityDelta);
        console2.log("liquidity", liquidity);
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);
        console2.log("ETH Balance after Increase Liquidity Position", address(this).balance);
        console2.log("USDC Balance after Increase Liquidity Position", usdc.balanceOf(address(this)));

        // Decrease liquidity
        console2.log("--- Decrease liquidity ---");
        (amount0, amount1) =
            uni.decreaseLiquidityCurrentRangeTokenToEth(tokenId, liquidity);
        console2.log("usdc balance", weth.balanceOf(address(this)));
        console2.log("amount 0", amount0);
        console2.log("amount 1", amount1);

        // Collect fees after decrease liquidity
        (uint256 fee0, uint256 fee1) = uni.collectAllFeesTokenToEth(tokenId, address(this));
        console2.log("--- Collect fees ---");
        console2.log("fee 0", fee0);
        console2.log("fee 1", fee1);
        console2.log("ETH Balance after Decrease liquidity", address(this).balance);
        console2.log("USDC Balance after Decrease liquidity", usdc.balanceOf(address(this)));
    }

}