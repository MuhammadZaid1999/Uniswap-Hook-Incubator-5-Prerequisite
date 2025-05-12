/*
Uniswap V3 Single Hop Swap
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

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

contract UniswapV3SingleHopSwap {
    address constant SWAP_ROUTER_02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    ISwapRouter02 private constant router = ISwapRouter02(SWAP_ROUTER_02);
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    receive() external payable {}

    function swapExactInputSingleHop(uint256 amountIn, uint256 amountOutMin)
        external returns (uint256)
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(SWAP_ROUTER_02, amountIn);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: DAI,
            fee: 3000,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        return router.exactInputSingle(params);
    }

    function swapExactOutputSingleHop(uint256 amountOut, uint256 amountInMax)
        external
    {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        ISwapRouter02.ExactOutputSingleParams memory params = ISwapRouter02
            .ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: DAI,
            fee: 3000,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax,
            sqrtPriceLimitX96: 0
        });

        uint256 amountIn = router.exactOutputSingle(params);

        if (amountIn < amountInMax) {
            weth.approve(address(router), 0); // ------------ approve 0 weth to router address
            weth.transfer(msg.sender, amountInMax - amountIn);
        }
    }

    // -------------------------------------------------- //

    function swapExactInputEthToUsdc(uint256 amountOutMin) external payable 
        returns (uint256) 
    {
        require(msg.value > 0, "Must pass non-zero ETH");

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: USDC,
            fee: 3000,
            recipient: msg.sender,
            amountIn: msg.value,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = router.exactInputSingle{value: msg.value}(params);
        return amountOut;
    }

    function swapExactInputEthToToken(address token, uint256 amountOutMin) external payable {
        require(msg.value > 0, "Must pass non-zero ETH");

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: token,
            fee: 3000,
            recipient: msg.sender,
            amountIn: msg.value,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        router.exactInputSingle{value: msg.value}(params);
    }

    function swapExactInputTokenToToken(address token1, address token2, uint256 amountIn, uint256 amountOutMin)
        external
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
            tokenIn: token1,
            tokenOut: token2,
            fee: 3000,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        router.exactInputSingle(params);
    }

    function swapExactInputTokenToETH(address token1, uint256 amountIn, uint256 amountOutMin)
        external returns (uint256 amountOut)
    {
        dai.transferFrom(msg.sender, address(this), amountIn);
        dai.approve(address(router), amountIn);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
            tokenIn: token1,
            tokenOut: WETH,
            fee: 3000,
            recipient: address(this),
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        amountOut = router.exactInputSingle(params);
        IWETH(WETH).withdraw(amountOut);
        payable(msg.sender).transfer(amountOut);
    }

    function swapExactOutputEthToUsdc1(uint256 amountOut, uint256 amountInMax) external payable returns (uint256) {
        require(msg.value >= amountInMax, "Insufficient ETH sent");

        IWETH(WETH).deposit{value: amountInMax}();
        IWETH(WETH).approve(address(router), amountInMax);

        ISwapRouter02.ExactOutputSingleParams memory params = ISwapRouter02.ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: USDC,
            fee: 3000,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax,
            sqrtPriceLimitX96: 0
        });

        uint256 actualSpent = router.exactOutputSingle(params);

        uint256 refund;
        if (actualSpent < amountInMax) {
            refund = amountInMax - actualSpent;
            IWETH(WETH).withdraw(refund);
            payable(msg.sender).transfer(refund);
        }

        return refund;
    }

    function swapExactOutputEthToToken1(address tokenOut, uint256 amountOut, uint256 amountInMax) 
        external payable returns (uint256) 
    {
        require(msg.value >= amountInMax, "Insufficient ETH sent");

        IWETH(WETH).deposit{value: amountInMax}();
        IWETH(WETH).approve(address(router), amountInMax);

        ISwapRouter02.ExactOutputSingleParams memory params = ISwapRouter02.ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: tokenOut,
            fee: 3000,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax,
            sqrtPriceLimitX96: 0
        });

        uint256 actualSpent = router.exactOutputSingle(params);

        uint256 refund;
        if (actualSpent < msg.value) {
            refund = msg.value - actualSpent;
            IWETH(WETH).withdraw(refund);
            payable(msg.sender).transfer(refund);
        }

        return refund;
    }

    function swapExactOutputTokenToToken(address tokenIn, address tokenOut, uint256 amountOut, uint256 amountInMax) external {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountInMax);
        IERC20(tokenIn).approve(address(router), amountInMax);

        ISwapRouter02.ExactOutputSingleParams memory params = ISwapRouter02.ExactOutputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: 3000,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax,
            sqrtPriceLimitX96: 0
        });

        uint256 actualIn = router.exactOutputSingle(params);

        if (actualIn < amountInMax) {
            IERC20(tokenIn).approve(address(router), 0);
            IERC20(tokenIn).transfer(msg.sender, amountInMax - actualIn);
        }
    }

    function swapExactOutputTokenToEth(address tokenIn, uint256 amountOut, uint256 amountInMax) 
        external 
    {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountInMax);
        IERC20(tokenIn).approve(address(router), amountInMax);

        ISwapRouter02.ExactOutputSingleParams memory params = ISwapRouter02.ExactOutputSingleParams({
            tokenIn: tokenIn,
            tokenOut: WETH,
            fee: 3000,
            recipient: address(this),
            amountOut: amountOut,
            amountInMaximum: amountInMax,
            sqrtPriceLimitX96: 0
        });

        uint256 actualIn = router.exactOutputSingle(params);
        IWETH(WETH).withdraw(amountOut);
        payable(msg.sender).transfer(amountOut);

        if (actualIn < amountInMax) {
            IERC20(tokenIn).approve(address(router), 0);
            IERC20(tokenIn).transfer(msg.sender, amountInMax - actualIn);
        }
    }

}



/*
Test with Foundry

Single hop test
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {UniswapV3SingleHopSwap} from "../src/Counter.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

contract UniswapV3SingleHopSwapTest is Test {
    address private constant SWAP_ROUTER_02 =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant DAI_WETH_POOL_3000 =
        0xC2e9F25Be6257c210d7Adf0D4Cd6E3E881ba25f8;

    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant usdc = IERC20(USDC);
    UniswapV3SingleHopSwap private swap;

    uint256 private constant AMOUNT_IN = 1e18;
    uint256 private constant AMOUNT_OUT = 50 * 1e18;
    uint256 private constant MAX_AMOUNT_IN = 1e18;

    receive() external payable {}


    function setUp() public {
        swap = new UniswapV3SingleHopSwap();
        weth.deposit{value: AMOUNT_IN + MAX_AMOUNT_IN}();
        weth.approve(address(swap), type(uint256).max);
    }

    function test_swapExactInputSingleHop() public {
        uint256 amountOut = swap.swapExactInputSingleHop(AMOUNT_IN, 1);
        console2.log("amountOut", amountOut);
        
        uint256 d1 = dai.balanceOf(address(this));
        assertGt(amountOut, 0, "DAI balance = 0");
        assertGt(d1, 0, "DAI balance = 0");
        assertEq(amountOut, d1, "DAI balance != amountOut");
    }

    function test_swapExactOutputSingleHop() public {
        uint256 w0 = weth.balanceOf(address(this));
        uint256 d0 = dai.balanceOf(address(this));

        swap.swapExactOutputSingleHop(AMOUNT_OUT, MAX_AMOUNT_IN);
        uint256 w1 = weth.balanceOf(address(this));
        uint256 d1 = dai.balanceOf(address(this));

        assertLt(w1, w0, "WETH balance didn't decrease");
        assertGt(d1, d0, "DAI balance didn't increase");
        assertEq(weth.balanceOf(address(swap)), 0, "WETH balance of swap != 0");
        assertEq(dai.balanceOf(address(swap)), 0, "DAI balance of swap != 0");
    }

    // -------------------------------------------------- //

    function test_swapExactInputEthToUsdc() public {
        uint256 usdcBefore = usdc.balanceOf(address(this));
        uint256 amountOut = swap.swapExactInputEthToUsdc{value: 1 ether}(1);
        uint256 usdcAfter = usdc.balanceOf(address(this));
        
        assertGt(usdcAfter, usdcBefore, "Expected USDC to increase");
        assertGt(amountOut, 0, "USDC balance = 0");
        assertEq(usdcAfter, amountOut, "USDC balance != amountOut");
    }

    function test_swapExactInputEthToToken() public {
        uint256 tokenBefore = dai.balanceOf(address(this));
        swap.swapExactInputEthToToken{value: 1 ether}(DAI, 1);

        uint256 tokenAfter = dai.balanceOf(address(this));
        assertGt(tokenAfter, tokenBefore, "Expected token to increase");
    }

    function test_swapExactInputTokenToEth() public {
        uint256 amountIn = 10 * 1e18;       
        deal(address(dai), address(this), type(uint256).max);
        dai.approve(address(swap), amountIn);

        uint256 ethBefore = address(this).balance;

        uint256 amountOut = swap.swapExactInputTokenToETH(DAI, amountIn, 1);

        uint256 ethAfter = address(this).balance;

        assertGt(amountOut, 0, "Expected amountOut to be greater than 0");
        assertGt(ethAfter, ethBefore, "WETH not received");
        assertEq(ethAfter - ethBefore, amountOut, "Insufficient WETH received");
    }

    function test_swapExactInputTokenToToken() public {
        uint256 amountIn = 1 ether;
        uint256 usdcBefore = usdc.balanceOf(address(this));

        swap.swapExactInputTokenToToken(WETH, USDC, amountIn, 1); // Set minOut = 1 for test

        uint256 usdcAfter = usdc.balanceOf(address(this));
        assertGt(usdcAfter, usdcBefore, "USDC balance should increase");
    }

    function test_swapExactOutputEthToUsdc1() public {
        uint256 amountOut = 100 * 1e6; // 10 USDC
        uint256 amountInMax = 1 ether;

        uint256 usdcBefore = usdc.balanceOf(address(this));
      
        uint256 refund = swap.swapExactOutputEthToUsdc1{value: amountInMax}(amountOut, amountInMax);

        uint256 usdcAfter = usdc.balanceOf(address(this));
      
        assertGe(usdcAfter - usdcBefore, amountOut, "USDC not received");
        assertGt(amountInMax, refund, "Refund should be 0");
    }

    function test_swapExactOutputEthToToken1() public {
        uint256 amountOut = 10 * 1e18; // 10 DAI
        uint256 amountInMax = 1 * 1e18;

        uint256 daiBefore = dai.balanceOf(address(this));
       
        uint256 refund = swap.swapExactOutputEthToToken1{value: amountInMax}(DAI, amountOut, amountInMax);

        uint256 daiAfter = dai.balanceOf(address(this));
       
        assertEq(daiAfter - daiBefore, amountOut, "DAI not received");
        assertGt(amountInMax, refund, "Refund should be 0");
    }

    function test_swapExactOutputTokenToToken() public {
        uint256 amountOut = 10 * 1e18; // 10 USDC
        uint256 amountInMax = 1 ether;

        uint256 usdcBefore = usdc.balanceOf(address(this));

        swap.swapExactOutputTokenToToken(WETH, USDC, amountOut, amountInMax);

        uint256 usdcAfter = usdc.balanceOf(address(this));
        assertGe(usdcAfter - usdcBefore, amountOut, "USDC not received");

        // Ensure WETH refund happened
        assertEq(weth.balanceOf(address(swap)), 0, "Leftover WETH on contract");
    }

    function test_swapExactOutputTokenToEth() public {
        uint256 amountIn = 5000 * 1e18; // 5000 DAI
        uint256 amountOut = 1 ether;

        deal(address(dai), address(this), amountIn);
        dai.approve(address(swap), type(uint256).max);
        
        uint256 daiBefore = dai.balanceOf(address(this));
        uint256 ethBefore = address(this).balance;
        
        swap.swapExactOutputTokenToEth(DAI, amountOut, amountIn);

        uint256 daiAfter = dai.balanceOf(address(this));
        uint256 ethAfter = address(this).balance;
        
        assertLt(daiAfter, daiBefore, "DAI not received");
        assertGt(ethAfter, ethBefore, "WETH not received");
        assertEq(ethAfter - ethBefore, amountOut, "Insufficient WETH received");
    }
}