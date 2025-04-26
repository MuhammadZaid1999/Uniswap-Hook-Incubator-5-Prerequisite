// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

struct Point {
    uint256 x;
    uint256 y;
}

error Unauthorized(address caller);

function add(uint256 x, uint256 y) pure returns (uint256) {
    return x + y;
}

function getPoint(uint256 _x, uint256 _y) pure returns (Point memory) {
    return Point({
        x: _x,
        y: _y
    });
}

contract Foo {
    string public name = "Foo";

    function setFoo(string memory _name) external {
        name = _name;
    }
}
