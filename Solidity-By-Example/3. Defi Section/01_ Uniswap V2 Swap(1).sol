/*
swapExactTokensForTokens sells all tokens for another.
swapTokensForExactTokens buys specific amount of tokens set by the caller.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IWETH} from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

contract UniswapV2SwapExamples {
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    
    // ---------- Addresses For Ethereum Mainnet ----------
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    

    // ---- Addresses For Ethereum Sepolia Testnet ----------
    // address private constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
    // address private constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
    // address private constant USDC = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    IUniswapV2Router02 private router = IUniswapV2Router02(UNISWAP_V2_ROUTER);
    IERC20 private weth = IERC20(WETH);
    IERC20 private dai = IERC20(DAI);

    // Allow contract to receive ETH
    receive() external payable {}

    // Swap WETH to DAI
    function swapSingleHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        // amounts[0] = WETH amount, amounts[1] = DAI amount
        return amounts[1];
    }

    // Swap DAI -> WETH -> USDC
    function swapMultiHopExactAmountIn(uint256 amountIn, uint256 amountOutMin)
        external
        returns (uint256 amountOut)
    {
        dai.transferFrom(msg.sender, address(this), amountIn);
        dai.approve(address(router), amountIn);

        address[] memory path;
        path = new address[](3);
        path[0] = DAI;
        path[1] = WETH;
        path[2] = USDC;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );

        // amounts[0] = DAI amount
        // amounts[1] = WETH amount
        // amounts[2] = USDC amount
        return amounts[2];
    }

    // Swap WETH to DAI
    function swapSingleHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        address[] memory path;
        path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired, amountInMax, path, msg.sender, block.timestamp
        );

        // Refund WETH to msg.sender
        if (amounts[0] < amountInMax) {
            weth.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[1];
    }

    // Swap DAI -> WETH -> USDC
    function swapMultiHopExactAmountOut(
        uint256 amountOutDesired,
        uint256 amountInMax
    ) external returns (uint256 amountOut) {
        dai.transferFrom(msg.sender, address(this), amountInMax);
        dai.approve(address(router), amountInMax);

        address[] memory path;
        path = new address[](3);
        path[0] = DAI;
        path[1] = WETH;
        path[2] = USDC;

        uint256[] memory amounts = router.swapTokensForExactTokens(
            amountOutDesired, amountInMax, path, msg.sender, block.timestamp
        );

        // Refund DAI to msg.sender
        if (amounts[0] < amountInMax) {
            dai.transfer(msg.sender, amountInMax - amounts[0]);
        }

        return amounts[2];
    }

    // --- Remaining interface functions below ---

    // Swap ETH -> Tokens (e.g., ETH -> DAI)
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path)
        external
        payable
        returns (uint[] memory amounts)
    {
        // Swap ETH sent with msg.value to tokens
        amounts = router.swapExactETHForTokens{value: msg.value}(
            amountOutMin, path, msg.sender, block.timestamp
        );
    }

    // Swap Tokens -> ETH (e.g., DAI -> ETH), buying exact ETH
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path)
        external
        returns (uint[] memory)
    {
        // Transfer input tokens from user
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
        // Approve router
        IERC20(path[0]).approve(address(router), amountInMax);

        // Execute swap
        uint[] memory amounts = router.swapTokensForExactETH(
            amountOut, amountInMax, path, msg.sender, block.timestamp
        );

        // Refund excess tokens if any
        if (amounts[0] < amountInMax) {
            IERC20(path[0]).transfer(msg.sender, amountInMax - amounts[0]);
        }

        // Return amounts array
        return amounts;
    }

    // Swap Tokens -> ETH (e.g., WETH -> ETH), selling exact input
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path)
        external
        returns (uint[] memory)
    {
        // Transfer tokens from user
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Approve router
        IERC20(path[0]).approve(address(router), amountIn);

        // Execute swap
        uint256[] memory amounts = router.swapExactTokensForETH(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );
        return amounts;
    }

    // Swap ETH -> Tokens (e.g., ETH -> USDC), buying exact output
    function swapETHForExactTokens(uint amountOut, address[] calldata path)
        external
        payable
        returns (uint[] memory)
    {
        // Execute swap using ETH sent with msg.value
        return router.swapETHForExactTokens{value: msg.value}(
            amountOut, path, msg.sender, block.timestamp
        );
    }

    // Swap Tokens -> Tokens supporting fee-on-transfer tokens
    // Swap DAI -> WETH -> USDC (fee-on-transfer)
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path
    ) external {
        // Transfer tokens from user
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Approve router
        IERC20(path[0]).approve(address(router), amountIn);

        // Execute swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );
    }

    // Swap ETH -> Tokens supporting fee-on-transfer tokens
    // Swap ETH -> USDC (fee-on-transfer)
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path
    ) external payable {
        // Execute swap using ETH
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            amountOutMin, path, msg.sender, block.timestamp
        );
    }

    // Swap Tokens -> ETH supporting fee-on-transfer tokens
    // Swap DAI -> ETH (fee-on-transfer)
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path
    ) external {
        // Transfer input token
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        // Approve router
        IERC20(path[0]).approve(address(router), amountIn);

        // Execute swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn, amountOutMin, path, msg.sender, block.timestamp
        );
    }

    function getAmountsOut(uint256 amountIn, address[] memory path) public view returns (uint256[] memory amounts) {
        return router.getAmountsOut(amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path) public view returns (uint256[] memory amounts) {
        return router.getAmountsIn(amountOut, path);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public view returns (uint256) {
        return router.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public view returns (uint256) {
        return router.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) public view returns (uint256) {
        return router.quote(amountA, reserveA, reserveB);
    }

    function factory() public view returns (address) {
        return router.factory();
    }

    function WETH_ADDRESS() public view returns (address) {
        return router.WETH();
    }

}



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Vm} from "forge-std/Vm.sol"; 
import {Test, console2} from "forge-std/Test.sol";
import {
    UniswapV2SwapExamples,
    IERC20,
    IWETH
} from "../src/Counter.sol";


contract UniswapV2SwapExamplesTest is Test {

    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    // ---------- Addresses For Ethereum Mainnet ----------
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // ---- Addresses For Ethereum Sepolia Testnet ----------
    // address private constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
    // address private constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
    // address private constant USDC = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    IERC20 private weth = IERC20(WETH);
    IWETH private weth1 = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);
    IERC20 private usdc = IERC20(USDC);

    UniswapV2SwapExamples private uni = new UniswapV2SwapExamples();

    // Allow contract to receive ETH
    receive() external payable {}

    function setUp() public {}

    // Swap WETH -> DAI
    function testSwapSingleHopExactAmountIn() public {
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 daiAmountMin = 1;
        uint256 daiAmountOut =
            uni.swapSingleHopExactAmountIn(wethAmount, daiAmountMin);
            
        console2.log("DAI", daiAmountOut);
        assertGe(daiAmountOut, daiAmountMin, "amount out < min");
    }

    // Swap DAI -> WETH -> USDC
    function testSwapMultiHopExactAmountIn() public {
        // Swap WETH -> DAI
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 daiAmountMin = 1;
         uni.swapSingleHopExactAmountIn(wethAmount, daiAmountMin);

        // Swap DAI -> WETH -> USDC
        uint256 daiAmountIn = 1e18;
        dai.approve(address(uni), daiAmountIn);

        uint256 usdcAmountOutMin = 1;
        uint256 usdcAmountOut =
            uni.swapMultiHopExactAmountIn(daiAmountIn, usdcAmountOutMin);

        console2.log("USDC", usdcAmountOut);
        assertGe(usdcAmountOut, usdcAmountOutMin, "amount out < min");
    }

    function testSwapMultiHopExactAmountIn1() public {
        // Swap WETH -> DAI
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 daiAmountMin = 1;
        uint256 daiAmountOut = uni.swapSingleHopExactAmountIn(wethAmount, daiAmountMin);

        // Swap DAI -> WETH -> USDC
        dai.approve(address(uni), daiAmountOut);

        uint256 usdcAmountOutMin = 1;
        uint256 usdcAmountOut =
            uni.swapMultiHopExactAmountIn(daiAmountOut, usdcAmountOutMin);

        console2.log("USDC", usdcAmountOut);
        assertGe(usdcAmountOut, usdcAmountOutMin, "amount out < min");
    }

    // Swap WETH -> DAI
    function testSwapSingleHopExactAmountOut() public {
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        uint256 daiAmountDesired = 1200e18;
        uint256 daiAmountOut =
            uni.swapSingleHopExactAmountOut(daiAmountDesired, wethAmount);

        console2.log("DAI", daiAmountOut);
        assertEq(
            daiAmountOut, daiAmountDesired, "amount out != amount out desired"
        );
    }

    // Swap DAI -> WETH -> USDC
    function testSwapMultiHopExactAmountOut() public {
        // Swap WETH -> DAI
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);

        // Buy 1000 DAI
        uint256 daiAmountOut = 1000 * 1e18;
        uni.swapSingleHopExactAmountOut(daiAmountOut, wethAmount);

        // Swap DAI -> WETH -> USDC
        dai.approve(address(uni), daiAmountOut);

        uint256 amountOutDesired = 950e6;
        uint256 amountOut =
            uni.swapMultiHopExactAmountOut(amountOutDesired, daiAmountOut);

        console2.log("USDC", amountOut);
        assertEq(
            amountOut, amountOutDesired, "amount out != amount out desired"
        );
    }

    // Swap ETH -> DAI
    function testSwapExactETHForTokens() public {
        uint256 ethAmount = 1e18; // 1 ETH
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint256 daiBefore = dai.balanceOf(address(this));
        uint256[] memory amounts = uni.swapExactETHForTokens{value: ethAmount}(1, path);

        uint256 daiAfter = dai.balanceOf(address(this));
        console2.log("DAI", daiAfter - daiBefore);
        assertGt(daiAfter, daiBefore, "No DAI received");
    }

    // Swap DAI -> ETH (tokensForExactETH)
    function testSwapTokensForExactETH() public {
        // Fund DAI
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);
        uni.swapSingleHopExactAmountIn(wethAmount, 1);

        // Swap DAI -> ETH
        uint256 amountOut = 0.1 ether;
        uint256 amountInMax = 1000 ether;
        dai.approve(address(uni), amountInMax);

        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = WETH;

        uint256 ethBalanceBefore = address(this).balance;
        uint256[] memory amounts = uni.swapTokensForExactETH(amountOut, amountInMax, path);
        uint256 ethBalanceAfter = address(this).balance;

        console2.log("ETH received", ethBalanceAfter - ethBalanceBefore);
        assertEq(amounts[1], amountOut, "Incorrect ETH received");
    }

    // Swap DAI -> ETH (exactTokensForETH)
    function testSwapExactTokensForETH() public {
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);
        uni.swapSingleHopExactAmountIn(wethAmount, 1);

        uint256 amountIn = 1e18;
        dai.approve(address(uni), amountIn);

        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = WETH;

        uint256 ethBefore = address(this).balance;
        uint256[] memory amounts = uni.swapExactTokensForETH(amountIn, 1, path);
        uint256 ethAfter = address(this).balance;

        console2.log("ETH received", ethAfter - ethBefore);
        assertGt(ethAfter, ethBefore, "No ETH received");
    }

    // Swap ETH -> DAI (ETH for exact tokens)
    function testSwapETHForExactTokens() public {
        uint256 ethAmount = 1e18;
        uint256 amountOut = 1500e18;
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint256 daiBefore = dai.balanceOf(address(this));
        console2.log("DAI before", daiBefore);
        console2.log("Eth before", address(uni).balance);
        uint256[] memory amounts = uni.swapETHForExactTokens{value: ethAmount}(amountOut, path);
        uint256 daiAfter = dai.balanceOf(address(this));
        console2.log("DAI after", daiAfter);
        console2.log("Eth after", address(uni).balance);
        console2.log("DAI", daiAfter - daiBefore);
        assertEq(amounts[1], amountOut, "Incorrect DAI amount");
    }

    // Fee-on-transfer: DAI -> USDC
    function testSwapExactTokensForTokensSupportingFeeOnTransfer() public {
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);
        uni.swapSingleHopExactAmountIn(wethAmount, 1);

        uint256 daiAmount = 1e18;
        dai.approve(address(uni), daiAmount);

        address[] memory path = new address[](3);
        path[0] = DAI;
        path[1] = WETH;
        path[2] = USDC;

        uint256 usdcBefore = usdc.balanceOf(address(this));
        uni.swapExactTokensForTokensSupportingFeeOnTransferTokens(daiAmount, 1, path);
        uint256 usdcAfter = usdc.balanceOf(address(this));

        console2.log("USDC", usdcAfter - usdcBefore);
        assertGt(usdcAfter, usdcBefore, "No USDC received");
    }

    // Fee-on-transfer: ETH -> USDC
    function testSwapExactETHForTokensSupportingFeeOnTransfer() public {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = USDC;

        uint256 usdcBefore = usdc.balanceOf(address(this));
        uni.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 1 ether}(1, path);
        uint256 usdcAfter = usdc.balanceOf(address(this));

        console2.log("USDC", usdcAfter - usdcBefore);
        assertGt(usdcAfter, usdcBefore, "No USDC received");
    }

    // Fee-on-transfer: DAI -> ETH
    function testSwapExactTokensForETHSupportingFeeOnTransfer() public {
        uint256 wethAmount = 1e18;
        weth1.deposit{value: wethAmount}();
        weth.approve(address(uni), wethAmount);
        uni.swapSingleHopExactAmountIn(wethAmount, 1);

        uint256 daiAmount = 1e18;
        dai.approve(address(uni), daiAmount);

        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = WETH;

        uint256 ethBefore = address(this).balance;
        uni.swapExactTokensForETHSupportingFeeOnTransferTokens(daiAmount, 1, path);
        uint256 ethAfter = address(this).balance;

        console2.log("ETH received", ethAfter - ethBefore);
        assertGt(ethAfter, ethBefore, "No ETH received");
    }

    function testGetAmountsOut() public view{
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint256 amountIn = 1 ether;
        uint256[] memory amounts = uni.getAmountsOut(amountIn, path);
        console2.log("amount0", amounts[0]);
        console2.log("amount1", amounts[1]);

        console2.log("ETH In:", amountIn);
        console2.log("DAI Out (est.):", amounts[1]);

        assertGt(amounts[1], 0, "Expected output must be > 0");
    }

    function testGetAmountsOut1() public view{
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = USDC;

        uint256 amountIn = 1 ether;
        uint256[] memory amounts = uni.getAmountsOut(amountIn, path);
        console2.log("amount0", amounts[0]);
        console2.log("amount1", amounts[1]);
        console2.log("amount2", amounts[2]);

        console2.log("ETH In:", amountIn);
        console2.log("USDC Out (est.):", amounts[2]);

        assertGt(amounts[2], 0, "Expected output must be > 0");
    }

    function testGetAmountsIn() public view{
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = DAI;

        uint256 amountOut = 100 * 1e18; // 100 DAI
        uint256[] memory amounts = uni.getAmountsIn(amountOut, path);
        console2.log("amount0", amounts[0]);
        console2.log("amount1", amounts[1]);

        console2.log("DAI Out:", amountOut);
        console2.log("ETH In Required (est.):", amounts[0]);

        assertGt(amounts[0], 0, "Expected input must be > 0");
    }

    function testGetAmountsIn1() public view{
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = USDC;

        uint256 amountOut = 100 * 1e6; // 100 USDC
        uint256[] memory amounts = uni.getAmountsIn(amountOut, path);
        console2.log("amount0", amounts[0]);
        console2.log("amount1", amounts[1]);
        console2.log("amount2", amounts[2]);

        console2.log("USDC Out:", amountOut);
        console2.log("ETH In Required (est.):", amounts[0]);

        assertGt(amounts[0], 0, "Expected input must be > 0");
    }

    function testQuote() public view {
        uint256 amountA = 2e18;
        uint256 reserveA = 10e18;
        uint256 reserveB = 20e18;

        uint256 quoted = uni.quote(amountA, reserveA, reserveB);

        console2.log("Quote (tokenB for tokenA):", quoted);
        assertEq(quoted, 4e18); // Expected: amountA * reserveB / reserveA
    }

    function testGetAmountOut() public view {
        uint256 amountIn = 1e18;
        uint256 reserveIn = 10e18;
        uint256 reserveOut = 20e18;

        uint256 out = uni.getAmountOut(amountIn, reserveIn, reserveOut);
        console2.log("Estimated Amount Out:", out);

        assertGt(out, 1.8e18, "Output must be > 0"); // amountIn * reserveOut / (reserveIn + amountIn)
    }

    function testGetAmountIn() public view {
        uint256 amountOut = 1e18;
        uint256 reserveIn = 10e18;
        uint256 reserveOut = 20e18;

        uint256 inRequired = uni.getAmountIn(amountOut, reserveIn, reserveOut);
        console2.log("Estimated Amount In:", inRequired);

        assertGt(inRequired, 0.5e18, "Input must be > 0"); // amountOut * reserveIn / (reserveOut - amountOut)
    }

    function testFactory() public view {
        address factoryAddr = uni.factory();
        console2.log("Uniswap V2 Factory:", factoryAddr);
        assert(factoryAddr == FACTORY); // factory address should be equals
    }

    function testWETHAddress() public view {
        address wethAddr = uni.WETH_ADDRESS();
        console2.log("WETH Address:", wethAddr);
        assertEq(wethAddr, WETH); // weth address should be the same as the WETH address
    }
}