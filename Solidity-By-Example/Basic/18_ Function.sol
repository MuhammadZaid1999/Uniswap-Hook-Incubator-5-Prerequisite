/*
There are several ways to return outputs from a function.
Public functions cannot accept certain data types as inputs or outputs
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Function {
    // Functions can return multiple values.
    function returnMany() public pure returns (uint256, bool, uint256) {
        return (1, true, 2);
    }

    // Return values can be named.
    function named() public pure returns (uint256 x, bool b, uint256 y) {
        return (1, true, 2);
    }

    // Return values can be assigned to their name.
    // In this case the return statement can be omitted.
    function assigned() public pure returns (uint256 x, bool b, uint256 y) {
        x = 1;
        b = true;
        y = 2;
    }

    // Use destructuring assignment when calling another
    // function that returns multiple values.
    function destructuringAssignments()
        public
        pure
        returns (uint256, bool, uint256, uint256, uint256, uint256, bool)
    {
        (uint256 i, bool b, uint256 j) = returnMany();

        // Values can be left out.
        (uint256 x,, uint256 y) = (4, 5, 6);

        // Values can be left out.
        (uint256 a1, bool b1) = (x, b);

        return (i, b, j, x, y, a1, b1);
    }

    // Cannot use map for either input or output

    // Can use array for input
    function arrayInput(uint256[] memory _arr) public {}

    // Can use array for output
    uint256[] public arr;

    function arrayOutput() public view returns (uint256[] memory) {
        return arr;
    }

    function arrayOutput1(uint256[3] memory _arr) public pure returns (uint256[3] memory) {
        _arr[0] = 1;
        _arr[1] = _arr[1];
        _arr[2] = 3;

        return _arr;
    }

    function arrayOutput2() public pure returns (uint256[3] memory, uint256[3] memory) {
        uint256[3] memory _arr = [uint(1), 2, 3];
        
        uint256[3] memory _arr1 = [uint(1), 2, 3];
        _arr1[0] = 4;
        _arr1[1] = 5;
        _arr1[2] = 6;

        return (_arr, _arr1);
    }
}

// Call function with key-value inputs
contract XYZ {
    function someFuncWithManyInputs(
        uint256 x,
        uint256 y,
        uint256 z,
        address a,
        bool b,
        string memory c
    ) public pure returns (uint256) {}

    function callFunc() external pure returns (uint256) {
        uint a = someFuncWithManyInputs(1, 2,3, address(0), true, "");

        return someFuncWithManyInputs(1, 2, 3, address(0), true, "c");
    }

    function callFuncWithKeyValue() external pure returns (uint256) {
        uint256 a = someFuncWithManyInputs({
            a: address(0),
            b: true,
            c: "c",
            x: 1,
            y: 2,
            z: 3
        });

        return someFuncWithManyInputs({
            a: address(0),
            b: true,
            c: "c",
            x: 1,
            y: 2,
            z: 3
        });
    }
}
