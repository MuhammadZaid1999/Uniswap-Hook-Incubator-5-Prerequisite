/*
You can import local and external files in Solidity.
 1. Local
    Here is our folder structure.
        ├── Import.sol
        └── Foo.sol
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import Foo.sol from current directory
import "./Foo.sol";

// import {symbol1 as alias, symbol2} from "filename";
import {Unauthorized, add, Point} from "./Foo.sol";
import {Unauthorized as unAuthorized, add as func, Point as pt} from "./Foo.sol";

contract Import {
    // Initialize Foo.sol
    Foo public foo = new Foo();

    Foo.Point1 public point = Foo.Point1(10, 20);

    // Test Foo.sol by getting its name.
    function getFooName() public view returns (string memory) {
        return foo.name();
    }

    function setFooName(string memory name) public {
        return foo.setFoo(name);
    }

    function setAdd(uint256 x, uint256 y) public pure returns (uint256) {
        return add(x, y);
    }

     function setAdd1(uint256 x, uint256 y) public pure returns (uint256) {
        return func(x, y);
    }

    function getPoints(uint256 x, uint256 y) public pure returns (pt memory) {
        pt memory p = getPoint(x, y);
        return p;
    }

    function getPoints1(uint256 x, uint256 y) public pure returns (pt memory) {
        return getPoint(x, y);
    }

    function setFooPoint(uint256 x, uint256 y) public {
        point = Foo.Point1(x, y);
    }

    function setFooPoint1(uint256 x, uint256 y) public {
        Foo.Point1 memory pt1 = Foo.Point1(x, y);
        point = pt1;
    }

    function setFooPoint2(uint256 x, uint256 y) external returns(Foo.Point1 memory) {
        Foo.Point1 storage pt1 = point;
        pt1.x = x;
        pt1.y = y;
        return pt1;
    }

    function getError(address addr) public view{
        if (msg.sender == addr) revert unAuthorized(addr);
    }
}

/*
 2. External
 You can also import from GitHub by simply copying the url.
*/

// https://github.com/owner/repo/blob/branch/path/to/Contract.sol
// import "https://github.com/owner/repo/blob/branch/path/to/Contract.sol";

// Example import ECDSA.sol from openzeppelin-contract repo, release-v4.5 branch
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";
