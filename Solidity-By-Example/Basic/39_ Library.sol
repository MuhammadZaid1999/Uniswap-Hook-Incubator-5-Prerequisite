/*
Libraries are similar to contracts, but you can't declare any state variables and you can't send ether.
A library is embedded into the contract if all library functions are internal.
Otherwise the library must be deployed and then linked before the contract is deployed.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library Math {
    uint8 private constant a = 1;
    uint8 public constant b = 2;
    uint8 internal constant c = 3;
    uint8 constant d = 4;

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0 (default value)
    }

    function pow(uint256 y) internal pure returns (uint256 z) {
        z = y ** a;
    }
}

contract TestMath {
    function testSquareRoot(uint256 x) public pure returns (uint256) {
        return Math.sqrt(x);
    }

    function testPower(uint256 x) public pure returns (uint256) {
        return x ** Math.c;
    }

    function testPower1(uint256 x) public pure returns (uint256) {
        return Math.pow(x);
    }

    function testAdd(uint256 x) public pure returns (uint256) {
        return Math.c + x;
    }

     function testDiv(uint256 x) public pure returns (uint256) {
        return x / Math.d;
    }
}

// Array function to delete element at index and re-organize the array
// so that there are no gaps between the elements.
library Array {
    struct Str {
        uint256 a;
        string b;
        bytes4 c;
        address d;
    }

    function testStruct(uint256 a, string memory b, bytes4 c, address d) public pure returns (Str memory) {
        return Str({a: a, b: b, c: c, d: d});
    }

    function remove(uint256[] storage arr, uint256 index) public {
        // Move the last element into the place to delete
        require(arr.length > 0, "Can't remove from empty array");
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }
}

contract TestArray {
    using Array for uint256[];

    uint256[] public arr;

    function testArrayRemove() public {
        for (uint256 i = 0; i < 3; i++) {
            arr.push(i);
        }

        arr.remove(1);

        assert(arr.length == 2);
        assert(arr[0] == 0);
        assert(arr[1] == 2);
    }
}
