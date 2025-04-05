// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Counter {
    uint256 public count;
    int256 public count1;

    // Function to get the current count
    function get() public view returns (uint256) {
        return count;
    }

    // Function to increment count by 1
    function inc() public {
        count += 1;
    }

    // Function to decrement count by 1
    function dec() public {
        // This function will fail if count = 0
        count -= 1;
    }

    // Function to get the current count
    function get1() public view returns (int256) {
        return count1;
    }

    // Function to increment count by 1
    function inc1() public {
        count1 += 1;
    }

    // Function to decrement count by 1
    function dec1() public {
        count1 -= 1;
    }
}
