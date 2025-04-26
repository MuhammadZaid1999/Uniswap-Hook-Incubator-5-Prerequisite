/*
You can interact with other contracts by declaring an Interface.
Interface
    cannot have any functions implemented
    can inherit from other interfaces
    all declared functions must be external
    cannot declare a constructor
    cannot declare state variables
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Counter {
    uint256 public count;

    function increment() external {
        count += 1;
    }

    function increment1() internal  {
        count += 1;
    }

    /*
    ------------- cannot declare internal or private function if calling through intreface -------------
    function increment1() internal  {
        count += 1;
    }
    function increment1() private  {
        count += 1;
    }
    */
}

interface ICounter {
    function count() external view returns (uint256);

    function increment() external;

    function increment1() external;
}

contract MyContract {
    function incrementCounter(address _counter) private {
        ICounter(_counter).increment();
    }

    function incrementCounter1(address _counter) public  {
        ICounter(_counter).increment1();
    }

    function incrementCounter2(address _counter) internal  {
        ICounter(_counter).increment1();
    }

    function incrementCounter3(address _counter) external  {
        ICounter(_counter).increment();
    }

    function getCount(address _counter) external view returns (uint256) {
        return ICounter(_counter).count();
    }

    function getCount1(address _counter) public view returns (uint256) {
        return ICounter(_counter).count();
    }

    function getCount2(address _counter) internal view returns (uint256) {
        return ICounter(_counter).count();
    }

    function getCount3(address _counter) private view returns (uint256) {
        return ICounter(_counter).count();
    }
}


// Uniswap example
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract UniswapExample {
    address private factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function getTokenReserves() external view returns (uint256, uint256) {
        address pair = IUniswapV2Factory(factory).getPair(dai, weth);
        (uint256 reserve0, uint256 reserve1,) =
            IUniswapV2Pair(pair).getReserves();
        return (reserve0, reserve1);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function mint(address to, uint256 value) external payable returns (bool);

    function allowance(address owner, address spender) external pure returns (uint256);
}

contract MyERC20 is IERC20 {
    mapping (address => uint256) private _balanceOf;
    uint256 private _totalSupply;

    // constructor () {
    //     balanceOf[msg.sender] = _totalSupply();
    // }

    function balanceOf(address addr) public view virtual  returns (uint256) {
        return _balanceOf[addr];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = msg.sender;
        _balanceOf[owner] -= value;
        _balanceOf[to] += value;
        emit Transfer(owner, to, value);

        return true;
    }

    function mint(address to, uint256 amount) public payable returns (bool) {
        _balanceOf[to] += amount;
        _totalSupply += amount;
        return true;
    }

    function burn(address to, uint256 amount) external returns (bool) {
        _balanceOf[to] -= amount;
        _totalSupply -= amount;
        return true;
    }

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function allowance(address owner, address spender) public pure returns (uint256){
        return 1;
    }

}