// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV2AddLiquidity {
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    receive() external payable {}

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    ) external {
        safeTransferFrom(IERC20(_tokenA), msg.sender, address(this), _amountA);
        safeTransferFrom(IERC20(_tokenB), msg.sender, address(this), _amountB);

        safeApprove(IERC20(_tokenA), ROUTER, _amountA);
        safeApprove(IERC20(_tokenB), ROUTER, _amountB);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = IUniswapV2Router02(
            ROUTER
        ).addLiquidity(
            _tokenA,
            _tokenB,
            _amountA,
            _amountB,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity1(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    ) external {
        
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);
        
        IERC20(_tokenA).approve(ROUTER, _amountA);
        IERC20(_tokenB).approve(ROUTER, _amountB);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = IUniswapV2Router02(
            ROUTER
        ).addLiquidity(
            _tokenA,
            _tokenB,
            _amountA,
            _amountB,
            1,
            1,
            address(this),
            block.timestamp
        );
    }

    function removeLiquidity(address _tokenA, address _tokenB) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint256 liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);

        (uint256 amountA, uint256 amountB) = IUniswapV2Router02(ROUTER)
            .removeLiquidity(
            _tokenA, _tokenB, liquidity, 1, 1, address(this), block.timestamp
        );
    }

    /**
     * @dev The transferFrom function may or may not return a bool.
     * The ERC-20 spec returns a bool, but some tokens don't follow the spec.
     * Need to check if data is empty or true.
     */
    function safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        (bool success, bytes memory returnData) = address(token).call(
            abi.encodeCall(token.transferFrom, (sender, recipient, amount))
        );
        require(
            success
                && (returnData.length == 0 || abi.decode(returnData, (bool))),
            "Transfer from fail"
        );
    }

    /**
     * @dev The approve function may or may not return a bool.
     * The ERC-20 spec returns a bool, but some tokens don't follow the spec.
     * Need to check if data is empty or true.
     */
    function safeApprove(IERC20 token, address spender, uint256 amount)
        internal
    {
        (bool success, bytes memory returnData) = address(token).call(
            abi.encodeCall(token.approve, (spender, amount))
        );
        require(
            success
                && (returnData.length == 0 || abi.decode(returnData, (bool))),
            "Approve fail"
        );
    }

    // ----------------- remaining functions ------------  

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        uint deadline
    ) external payable {
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);
        IERC20(token).approve(ROUTER, amountTokenDesired);

        (uint256 amountA, uint256 amountB, uint256 liquidity) = IUniswapV2Router02(ROUTER).addLiquidityETH{value: msg.value}(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
    }

    function removeLiquidityETH(
        address token,
        uint deadline
    ) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(token, WETH);
        uint256 liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);

        (uint256 amountToken, uint256 amountETH) = IUniswapV2Router02(ROUTER).removeLiquidityETH(
            token,
            liquidity,
            1,
            1,
            address(this),
            deadline
        );
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external {
        IUniswapV2Router02(ROUTER).removeLiquidityWithPermit(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            address(this),
            deadline,
            approveMax, v, r, s
        );
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external {
        IUniswapV2Router02(ROUTER).removeLiquidityETHWithPermit(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline,
            approveMax, v, r, s
        );
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint deadline
    ) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(token, WETH);
        uint256 liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);

        IUniswapV2Router02(ROUTER).removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            1,
            1,
            address(this),
            deadline
        );
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external {
        IUniswapV2Router02(ROUTER).removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline,
            approveMax, v, r, s
        );
    }
 
}



/*
 Test with Foundry
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {UniswapV2AddLiquidity, IUniswapV2Factory} from "../src/Counter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
IERC20 constant PAIR = IERC20(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852); // WETH/USDT
IERC20 constant PAIR1 = IERC20(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11); // WETH/DAI

contract UniswapV2AddLiquidityTest is Test {
    address private constant factory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    UniswapV2AddLiquidity private uni = new UniswapV2AddLiquidity();

    receive() external payable {}

    function setUp() public {
        // Deal tokens
        deal(address(DAI), address(this), 1_000_000 * 1e18);
        deal(address(WETH), address(this), 1_000 * 1e18);

        DAI.approve(address(uni), type(uint256).max);
        WETH.approve(address(uni), type(uint256).max);
    }

    //  Add WETH/USDT Liquidity to Uniswap
    function testAddLiquidity() public {
        // Deal test USDT and WETH to this contract
        deal(address(USDT), address(this), 1e6 * 1e6);
        assertEq(
            USDT.balanceOf(address(this)), 1e6 * 1e6, "USDT balance incorrect"
        );
        deal(address(WETH), address(this), 1e6 * 1e18);
        assertEq(
            WETH.balanceOf(address(this)), 1e6 * 1e18, "WETH balance incorrect"
        );

        // Approve uni for transferring
        safeApprove(WETH, address(uni), 1e64);
        safeApprove(USDT, address(uni), 1e64);

        uni.addLiquidity(address(WETH), address(USDT), 1 * 1e18, 3000.05 * 1e6);

        assertGt(PAIR.balanceOf(address(uni)), 0, "pair balance 0");
    }

    function testAddLiquidity1() public {
        assertEq(
            DAI.balanceOf(address(this)), 1_000_000 * 1e18, "DAI balance incorrect"
        );
        assertEq(
            WETH.balanceOf(address(this)), 1_000 * 1e18, "WETH balance incorrect"
        );

        uni.addLiquidity1(address(WETH), address(DAI), 5 * 1e18, 5000.05 * 1e18);

        assertGt(PAIR1.balanceOf(address(uni)), 0, "pair balance 0");
    }

    // Remove WETH/USDT Liquidity from Uniswap
    function testRemoveLiquidity() public {
        // Deal LP tokens to uni
        deal(address(PAIR), address(uni), 1e10);
        assertEq(PAIR.balanceOf(address(uni)), 1e10, "LP tokens balance = 0");
        assertEq(USDT.balanceOf(address(uni)), 0, "USDT balance non-zero");
        assertEq(WETH.balanceOf(address(uni)), 0, "WETH balance non-zero");

        uni.removeLiquidity(address(WETH), address(USDT));

        assertEq(PAIR.balanceOf(address(uni)), 0, "LP tokens balance != 0");
        assertGt(USDT.balanceOf(address(uni)), 0, "USDT balance = 0");
        assertGt(WETH.balanceOf(address(uni)), 0, "WETH balance = 0");
    }

    // Remove WETH/USDT Liquidity from Uniswap
    function testRemoveLiquidity1() public {
        // Deal LP tokens to uni
        deal(address(PAIR1), address(uni), 1e10);
        assertEq(PAIR1.balanceOf(address(uni)), 1e10, "LP tokens balance = 0");
        assertEq(DAI.balanceOf(address(uni)), 0, "DAI balance non-zero");
        assertEq(WETH.balanceOf(address(uni)), 0, "WETH balance non-zero");

        uni.removeLiquidity(address(WETH), address(DAI));

        assertEq(PAIR.balanceOf(address(uni)), 0, "LP tokens balance != 0");
        assertGt(DAI.balanceOf(address(uni)), 0, "DAI balance = 0");
        assertGt(WETH.balanceOf(address(uni)), 0, "WETH balance = 0");
    }


    /**
     * @dev The approve function may or may not return a bool.
     * The ERC-20 spec returns a bool, but some tokens don't follow the spec.
     * Need to check if data is empty or true.
     */
    function safeApprove(IERC20 token, address spender, uint256 amount)
        internal
    {
        (bool success, bytes memory returnData) = address(token).call(
            abi.encodeCall(IERC20.approve, (spender, amount))
        );
        require(
            success
                && (returnData.length == 0 || abi.decode(returnData, (bool))),
            "Approve fail"
        );
    }

    // ----------------- remaining functions ------------  

    function testAddLiquidityETH() public {
        uint amountToken = 1_000_000 * 1e18;

        uni.addLiquidityETH{value: 1 ether}(
            address(DAI),
            amountToken,
            1,
            1,
            block.timestamp
        );

        address pair = IUniswapV2Factory(factory).getPair(address(DAI), address(WETH));
        assertGt(IERC20(pair).balanceOf(address(uni)), 0);
    }

    function testRemoveLiquidityETH() public {
        uint amountToken = 1_000_000 * 1e18;
        uni.addLiquidityETH{value: 1 ether}(
            address(DAI),
            amountToken,
            1,
            1,
            block.timestamp
        );
        assertGt(PAIR1.balanceOf(address(uni)), 0, "pair balance 0");

        uni.removeLiquidityETH(address(DAI), block.timestamp);

        assertEq(PAIR1.balanceOf(address(uni)), 0, "LP tokens balance != 0");
        assertGt(DAI.balanceOf(address(uni)), 0);
        assertGt(address(uni).balance, 0);
    }
    

    // ------------ cannot use at this time ------------ 

    // function testRemoveLiquidityWithPermit() public {
    //     uni.addLiquidity(address(WETH), address(DAI), 1 ether, 3000 * 1e6);

    //     address pair = IUniswapV2Factory(factory).getPair(address(WETH), address(DAI));
    //     uint256 liquidity = IERC20(pair).balanceOf(address(uni));

    //     // You need to generate permit signature off-chain or via helper
    //     (uint8 v, bytes32 r, bytes32 s) = signPermit(pair, address(uni), liquidity);

    //     uni.removeLiquidityWithPermit(
    //         address(WETH),
    //         address(DAI),
    //         liquidity,
    //         1,
    //         1,
    //         block.timestamp,
    //         true, v, r, s
    //     );
    // }

    // function testRemoveLiquidityETHWithPermit() public {
    //     uni.addLiquidityETH{value: 1 ether}(
    //         address(DAI),
    //         1000 * 1e6,
    //         1,
    //         1,
    //         block.timestamp
    //     );

    //     address pair = IUniswapV2Factory(factory).getPair(address(DAI), address(WETH));
    //     uint256 liquidity = IERC20(pair).balanceOf(address(uni));
    //     (uint8 v, bytes32 r, bytes32 s) = signPermit(pair, address(uni), liquidity);

    //     uni.removeLiquidityETHWithPermit(
    //         address(DAI),
    //         liquidity,
    //         1,
    //         1,
    //         block.timestamp,
    //         true, v, r, s
    //     );
    // }

    // function testRemoveLiquidityETHSupportingFeeOnTransferTokens() public {
    //     uni.addLiquidityETH{value: 1 ether}(
    //         address(DAI),
    //         1000 * 1e6,
    //         1,
    //         1,
    //         block.timestamp
    //     );

    //     uni.removeLiquidityETHSupportingFeeOnTransferTokens(
    //         address(DAI),
    //         block.timestamp
    //     );
    // }

    // function testRemoveLiquidityETHWithPermitSupportingFeeOnTransferTokens() public {
    //     uni.addLiquidityETH{value: 1 ether}(
    //         address(DAI),
    //         1000 * 1e6,
    //         1,
    //         1,
    //         block.timestamp
    //     );

    //     address pair = IUniswapV2Factory(factory).getPair(address(DAI), address(WETH));
    //     uint256 liquidity = IERC20(pair).balanceOf(address(uni));
    //     (uint8 v, bytes32 r, bytes32 s) = signPermit(pair, address(uni), liquidity);

    //     uni.removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    //         address(DAI),
    //         liquidity,
    //         1,
    //         1,
    //         block.timestamp,
    //         true, v, r, s
    //     );
    // }

}
