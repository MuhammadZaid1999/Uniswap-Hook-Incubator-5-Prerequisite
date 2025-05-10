/*
Uniswap V3 Multi Hop Swap
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params)
        external
        payable
        returns (uint256 amountIn);     
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

contract UniswapV3MultiHopSwap {
    address constant SWAP_ROUTER_02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    ISwapRouter02 private constant router = ISwapRouter02(SWAP_ROUTER_02);
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    receive() external payable {}

    function swapExactInputMultiHop(uint256 amountIn, uint256 amountOutMin) 
        external returns (uint256) 
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        bytes memory path = abi.encodePacked(WETH, uint24(3000), USDC, uint24(100), DAI);

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02.ExactInputParams({
            path: path,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin
        });

        uint256 amountOut = router.exactInput(params);
        return amountOut;
    }

    function swapExactOutputMultiHop(uint256 amountOut, uint256 amountInMax) external {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        bytes memory path = abi.encodePacked(DAI, uint24(100), USDC, uint24(3000), WETH);

        ISwapRouter02.ExactOutputParams memory params = ISwapRouter02.ExactOutputParams({
            path: path,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax
        });

        uint256 amountIn = router.exactOutput(params);

        if (amountIn < amountInMax) {
            weth.approve(address(router), 0);
            weth.transfer(msg.sender, amountInMax - amountIn);
        }
    }

    function swapExactInputEthToTokenMultiHop(address tokenOut, uint256 amountOutMin) external 
        payable returns (uint256) 
    {
        require(msg.value > 0, "Must send ETH");
       
        IWETH(WETH).deposit{value: msg.value}();
        IWETH(WETH).approve(address(router), msg.value);

        bytes memory path = abi.encodePacked(WETH, uint24(3000), USDC, uint24(100), tokenOut);

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02.ExactInputParams({
            path: path,
            recipient: msg.sender,
            amountIn: msg.value,
            amountOutMinimum: amountOutMin
        });

        return router.exactInput(params);
    }

    function swapExactInputEthToTokenMultiHop1(bytes memory path, uint256 amountOutMin) 
        external payable 
    {
        require(msg.value > 0, "Must send ETH");
       
        IWETH(WETH).deposit{value: msg.value}();
        IWETH(WETH).approve(address(router), msg.value);

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02.ExactInputParams({
            path: path,
            recipient: msg.sender,
            amountIn: msg.value,
            amountOutMinimum: amountOutMin
        });

        router.exactInput(params);
    }

    function swapExactOutputEthToTokenMultiHop(address tokenOut, uint256 amountOut, uint256 amountInMax) external payable {
        require(msg.value >= amountInMax, "Insufficient ETH");
        IWETH(WETH).deposit{value: amountInMax}();
        IWETH(WETH).approve(address(router), amountInMax);

        bytes memory path = abi.encodePacked(tokenOut, uint24(100), USDC, uint24(3000), WETH);

        ISwapRouter02.ExactOutputParams memory params = ISwapRouter02.ExactOutputParams({
            path: path,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax
        });

        uint256 actualIn = router.exactOutput(params);

        if (actualIn < msg.value) {
            IWETH(WETH).withdraw(msg.value - actualIn);
            payable(msg.sender).transfer(msg.value - actualIn);
        }
    }

    function swapExactInputTokenToTokenMultiHop(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin) 
        external returns (uint256 amountOut)
    {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        bytes memory path = abi.encodePacked(tokenIn, uint24(3000), USDC, uint24(100), tokenOut);

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02.ExactInputParams({
            path: path,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin
        });

        amountOut = router.exactInput(params);
    }

    function swapExactInputTokenToTokenMultiHop1(bytes memory path, address tokenIn, uint256 amountIn, uint256 amountOutMin) 
        external
    {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02.ExactInputParams({
            path: path,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin
        });

        router.exactInput(params);
    }

    function swapExactOutputTokenToTokenMultiHop(address tokenIn, address tokenOut, uint256 amountOut, uint256 amountInMax) external {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountInMax);
        IERC20(tokenIn).approve(address(router), amountInMax);

        bytes memory path = abi.encodePacked(tokenOut, uint24(100), USDC, uint24(3000), tokenIn);

        ISwapRouter02.ExactOutputParams memory params = ISwapRouter02.ExactOutputParams({
            path: path,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax
        });

        uint256 actualIn = router.exactOutput(params);

        if (actualIn < amountInMax) {
            IERC20(tokenIn).approve(address(router), 0);
            IERC20(tokenIn).transfer(msg.sender, amountInMax - actualIn);
        }
    }

    function swapExactInputTokenToEthMultiHop(bytes memory path, address tokenIn, uint256 amountIn, uint256 amountOutMin) 
        external returns (uint256)
    {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02.ExactInputParams({
            path: path,
            recipient: address(this),
            amountIn: amountIn,
            amountOutMinimum: amountOutMin
        });
        uint256 amountOut = router.exactInput(params);

        IWETH(WETH).withdraw(amountOut);
        payable(msg.sender).transfer(amountOut);

        return amountOut;
    }

}



/*
Test with Foundry

Multi hop test
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UniswapV3MultiHopSwap} from "../src/Counter.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

contract UniswapV3MultiHopSwapTest is Test {
    address private constant SWAP_ROUTER_02 =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant usdc = IERC20(USDC);

    UniswapV3MultiHopSwap private swap;

    uint256 private constant AMOUNT_IN = 10 * 1e18;
    uint256 private constant AMOUNT_OUT = 20 * 1e18;
    uint256 private constant MAX_AMOUNT_IN = 1e18;

    receive() external payable {}

    function setUp() public {
        swap = new UniswapV3MultiHopSwap();
        weth.deposit{value: AMOUNT_IN + MAX_AMOUNT_IN}();
        weth.approve(address(swap), type(uint256).max);
    }

    function test_swapExactInputMultiHop() public {
        uint256 amountOut = swap.swapExactInputMultiHop(AMOUNT_IN, 1);
        uint256 d1 = dai.balanceOf(address(this));
        assertGt(d1, 0, "DAI balance = 0");
        assertEq(amountOut, d1, "Amount out is not correct");
    }

    function test_swapExactOutputMultiHop() public {
        uint256 w0 = weth.balanceOf(address(this));
        uint256 d0 = dai.balanceOf(address(this));
        swap.swapExactOutputMultiHop(AMOUNT_OUT, MAX_AMOUNT_IN);
        uint256 w1 = weth.balanceOf(address(this));
        uint256 d1 = dai.balanceOf(address(this));

        assertLt(w1, w0, "WETH balance didn't decrease");
        assertGt(d1, d0, "DAI balance didn't increase");
        assertEq(weth.balanceOf(address(swap)), 0, "WETH balance of swap != 0");
        assertEq(dai.balanceOf(address(swap)), 0, "DAI balance of swap != 0");
    }

    function test_swapExactInputEthToTokenMultiHop() public {
        uint256 amountIn = 1 ether;
        uint256 amountOutMin = 1;

        console2.log("beforeEth", address(this).balance);
        uint256 amountOut = swap.swapExactInputEthToTokenMultiHop{value: amountIn}(DAI, amountOutMin);

        uint256 daiBalance = dai.balanceOf(address(this));
        assertGt(daiBalance, 0, "DAI not received");
        assertEq(amountOut, daiBalance, "Amount out is not correct");
    }

    function test_swapExactInputEthToTokenMultiHop1() public {
        uint256 amountIn = 1 ether;
        uint256 amountOutMin = 1;
        bytes memory path = abi.encodePacked(WETH, uint24(3000), DAI, uint24(100), USDC);

        console2.log("beforeEth", address(this).balance);
        uint256 usdcBalanceBefore = usdc.balanceOf(address(this));

        swap.swapExactInputEthToTokenMultiHop1{value: amountIn}(path, amountOutMin);

        uint256 usdcBalanceAfter = usdc.balanceOf(address(this));
        assertGt(usdcBalanceAfter, usdcBalanceBefore, "USDC not received");
    }

    function test_swapExactOutputEthToTokenMultiHop() public {
        uint256 amountOut = 20 * 1e18;
        uint256 amountInMax = 1 ether;

        swap.swapExactOutputEthToTokenMultiHop{value: amountInMax}(DAI, amountOut, amountInMax);

        uint256 daiBalance = dai.balanceOf(address(this));
        assertGt(daiBalance, 0, "DAI not received");
    }

    function test_swapExactInputTokenToTokenMultiHop() public {
        uint256 amountOutMin = 1;

        uint256 daiBefore = dai.balanceOf(address(this));

        // Perform swap from WETH → USDC → DAI
        uint256 amountOut = swap.swapExactInputTokenToTokenMultiHop(WETH, DAI, AMOUNT_IN, amountOutMin);

        uint256 daiAfter = dai.balanceOf(address(this));
        assertGt(daiAfter, daiBefore, "DAI not received");
        assertEq(amountOut, daiAfter, "Amount out is not correct");
    }

    function test_swapExactInputTokenToTokenMultiHop1() public {
        uint256 amountOutMin = 1;
        uint256 amountIn = 100 * 1e18; // 100 DAI

        deal(DAI, address(this), amountIn);
        dai.approve(address(swap), amountIn);

        uint256 daiBefore = dai.balanceOf(address(this));
        uint256 usdcBefore = usdc.balanceOf(address(this));

        bytes memory path = abi.encodePacked(DAI, uint24(3000), WETH, uint24(100), USDC);
        // Perform swap from DAI → WETH → USDC
        swap.swapExactInputTokenToTokenMultiHop1(path, DAI, amountIn, amountOutMin);

        uint256 daiAfter = dai.balanceOf(address(this));
        uint256 usdcAfter = usdc.balanceOf(address(this));
       
        assertGt(daiBefore, daiAfter, "DAI not received");
        assertGt(usdcAfter, usdcBefore, "USDC not received");
    }

    function test_swapExactOutputTokenToTokenMultiHop() public {
        uint256 amountOut = 20 * 1e18;
        uint256 amountInMax = 1 ether;

        // Fund with WETH
        weth.deposit{value: amountInMax}();
        weth.approve(address(swap), amountInMax);

        uint256 daiBefore = dai.balanceOf(address(this));

        // Perform swap to receive exact DAI
        swap.swapExactOutputTokenToTokenMultiHop(WETH, DAI, amountOut, amountInMax);

        uint256 daiAfter = dai.balanceOf(address(this));
        assertGt(daiAfter, daiBefore, "DAI not received");
    }

    function test_swapExactInputTokenToEthMultiHop() public {
        uint256 amountOutMin = 1;
        uint256 amountIn = 100 * 1e18; // 100 DAI

        deal(DAI, address(this), amountIn);

        uint256 ethBefore = address(this).balance;
        uint256 daiBefore = dai.balanceOf(address(this));
        dai.approve(address(swap), amountIn);

        bytes memory path = abi.encodePacked(DAI, uint24(100), USDC, uint24(3000), WETH);
        
        uint256 amountOut = swap.swapExactInputTokenToEthMultiHop(path, DAI, amountIn, amountOutMin);

        uint256 ethAfter = address(this).balance;
        uint256 daiAfter = dai.balanceOf(address(this));

        assertEq(amountOut, ethAfter - ethBefore, "Amount out is not correct");
        assertGt(ethAfter, ethBefore, "ETH not received");
        assertLt(daiAfter, daiBefore, "DAI not received");
    }

}