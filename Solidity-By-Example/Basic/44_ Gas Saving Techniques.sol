/*
Some gas saving techniques.
    Replacing memory with calldata
    Loading state variables to memory
    Replace for loop i++ with ++i
    Caching array elements
    Short circuit
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// gas golf
contract GasGolf {
    // start - 50908 gas
    // use calldata - 49163 gas
    // load state variables to memory - 48952 gas
    // short circuit - 48634 gas
    // loop increments - 48244 gas
    // cache array length - 48209 gas
    // load array elements to memory - 48047 gas
    // uncheck i overflow/underflow - 47309 gas

    uint256 public total;
    uint8[] public numsbers;
    uint256 val;

    // start - not gas optimized
    function sumIfEvenAndLessThan99(uint[] memory nums) external {
        for (uint i = 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }

    // gas optimized
    // [1, 2, 3, 4, 5, 100]
    function _sumIfEvenAndLessThan99(uint256[] calldata nums) external {
        uint256 _total = total;
        uint256 len = nums.length;

        for (uint256 i = 0; i < len;) {
            uint256 num = nums[i];
            if (num % 2 == 0 && num < 99) {
                _total += num;
            }
            unchecked {
                ++i;
            }
        }

        total = _total;
    }

    function _sumIfEvenAndLessThan99() external {
        uint256 a = total + 10;
        uint256 b = total + 10;
        uint256 c = total + 10;
        uint256 d = total + 10;
        val = a + b + c + d;

        for (uint8 i = 0; i < 10; i++) {
            numsbers.push(i);
        }
    }

    function _sumIfEvenAndLessThan99_() external {
        uint256 _total = total;
        uint256 a = _total + 10;
        uint256 b = _total + 10;
        uint256 c = _total + 10;
        uint256 d = _total + 10;
        val = a + b + c + d;

        uint8 iter = 10;

        uint8[] memory _arr = new uint8[](iter);

        for (uint8 i = 0; i < iter;){ 
            _arr[i] = i;

            unchecked {
                ++i;
            }
        }
        numsbers = _arr;
    }
}