// Here we introduce you to some primitive data types available in Solidity.
// boolean
// uint256
// int256
// address

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Primitives {
    bool public boo = true;

    /*
    uint stands for unsigned integer, meaning non negative integers
    different sizes are available
        uint8   ranges from 0 to 2 ** 8 - 1
        uint16  ranges from 0 to 2 ** 16 - 1
        ...
        uint256 ranges from 0 to 2 ** 256 - 1
    */
    uint8 public u8 = 255;
    // uint8 public u8 = 256; ----> TypeError: Type int_const 256 is not implicitly convertible to expected type uint8. Literal is too large to fit in uint8.
    uint256 public u256 = 456;
    uint256 public u = 123; // uint is an alias for uint256

    /*
    Negative numbers are allowed for int types.
    Like uint, different ranges are available from int8 to int256
    
    int256 ranges from -2 ** 255 to 2 ** 255 - 1
    int128 ranges from -2 ** 127 to 2 ** 127 - 1
    ...
    uint8   ranges from -2 ** 7 to 2 ** 7 - 1
    */
    int8 public i8 = -1;
    // int8 public i8 = 128; ----> TypeError: Type int_const 128 is not implicitly convertible to expected type int8. Literal is too large to fit in int8.
    // int8 public i8 = -129; ----> TypeError: Type int_const -129 is not implicitly convertible to expected type int8. Literal is too large to fit in int8.
    int256 public i256 = 456;
    int256 public i = -123; // int is same as int256

    // minimum and maximum of int
    int256 public minInt = type(int256).min;
    int256 public maxInt = type(int256).max;
    int8 public minInt8 = type(int8).min;
    int8 public maxInt8 = type(int8).max;
    uint256 public minUint = type(uint256).min;
    uint256 public maxUint = type(uint256).max;
    uint8 public minUint8 = type(uint8).min;
    uint8 public maxUint8 = type(uint8).max;

    address public addr = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    /*
    In Solidity, the data type byte represent a sequence of bytes. 
    Solidity presents two types of bytes :

     - fixed-sized byte arrays
     - dynamically-sized byte arrays.
     
     The term bytes in Solidity represents a dynamic array of bytes. 
     It’s a shorthand for byte[] .
    */
    bytes1 a = 0xb5; //  [10110101]
    bytes1 b = 0x56; //  [01010110]

    // Default values
    // Unassigned variables have a default value
    bool public defaultBoo; // false
    uint256 public defaultUint; // 0
    int256 public defaultInt; // 0
    address public defaultAddr; // 0x0000000000000000000000000000000000000000

}