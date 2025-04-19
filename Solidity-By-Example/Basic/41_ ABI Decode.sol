/*
abi.encode encodes data into bytes.
abi.decode decodes bytes back into data.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AbiDecode {
    struct MyStruct {
        string name;
        uint256[2] nums;
        bytes20[] addr;
    }

    function encode(
        uint256 x,
        address addr,
        uint256[] calldata arr,
        MyStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }

    function encode1(
        uint256 x,
        address addr,
        uint256[6] calldata arr,
        MyStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }

    function decode(bytes calldata data)
        external
        pure
        returns (
            uint256 x,
            address addr,
            uint256[] memory arr,
            MyStruct memory myStruct
        )
    {
        // (uint x, address addr, uint[] memory arr, MyStruct myStruct) = ...
        (x, addr, arr, myStruct) =
            abi.decode(data, (uint256, address, uint256[], MyStruct));
    }

    function decode1(bytes calldata data)
        external
        pure
        returns (
            uint256 x,
            address addr,
            uint256[4] memory arr,
            MyStruct memory myStruct
        )
    {
        // (uint x, address addr, uint[] memory arr, MyStruct myStruct) = ...
        (x, addr, arr, myStruct) =
            abi.decode(data, (uint256, address, uint256[4], MyStruct));
    }
}
