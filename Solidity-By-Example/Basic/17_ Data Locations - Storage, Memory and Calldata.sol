/*
Variables are declared as either storage, memory or calldata to explicitly specify the location of the data.
    storage - variable is a state variable (stored on the blockchain)
    memory - variable is in memory and it exists while a function is being called
    calldata - special data location that contains function arguments
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DataLocations {
    uint256[] public arr;
    mapping(uint256 => address) public map;

    struct MyStruct {
        uint256 foo;
    }

    mapping(uint256 => MyStruct) public myStructs;

    function f() public {
        // call _f with state variables
        _f(arr, map, myStructs[1]);

        // get a struct from a mapping
        MyStruct storage myStruct = myStructs[1];
        // create a struct in memory
        MyStruct memory myMemStruct = MyStruct(0);
    }

    // works only internally with existing storage references.
    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something with storage variables
        _arr.push(5);
        _map[1] = address(1);
        _myStruct.foo = 1024;
    }

    // You can return memory variables
    function g(uint256[] memory _arr) public pure returns (uint256[] memory) {
        // do something with memory array
        _arr[0] = 1024;
        return _arr;
    }

    function h(uint256[] calldata _arr) public pure returns (uint256[] memory) {
        // do something with calldata array
        // _arr[0] = 1024; ----> TypeError: Calldata arrays are read-only.
        return _arr;
    }

    function i(
        // string storage a, ---> TypeError: Data location must be "memory" or "calldata" for parameter in function, but "storage" was given. 
        string memory b, 
        string calldata c
    ) public pure returns (string memory, string memory) {
        // c =  "c"; ----> TypeError: Type literal_string "c" is not implicitly convertible to expected type string calldata.
        b =  "b";
        return (b, c);    
    }
}

contract DataLocationDemo {
    uint[] public storageArray; // This lives in `storage`

    constructor() {
        // Initialize storageArray with some values
        storageArray.push(1);
        storageArray.push(2);
        storageArray.push(3);
    }

    //  Using `storage` — modifies the original array
    function modifyStorageArray() public {
        uint[] storage ref = storageArray;
        ref[0] = 100; 
    }

    //  Using `memory` — creates a temporary copy
    function modifyMemoryArray() public view returns (uint[] memory) {
        uint[] memory temp = storageArray; 
        temp[0] = 999; 
        return temp; 
    }

    function modifyMemoryArray1() public pure returns (uint[3] memory) {
        uint[3] memory temp = [uint(1),2,3]; 
        temp[0] = 999; 
        return temp; 
    }

    // Using `calldata` — read-only, used in external functions
    function readCalldataArray(uint[] calldata input) external pure returns (uint) {
        // input[0] = 5; //  Not allowed, calldata is read-only
        return input[0];
    }

    function getStorageArray() public view returns (uint[] memory) {
        return storageArray;
    }
}

contract DataLocationDemo1 {
    uint[] public nums;
   
    struct User {
        uint age;
    }
    User public user;

    function updateStorageArray() public {
        uint[] storage ref = nums; // reference to state variable
        ref.push(42);
    }

    // works only internally with existing storage references.
    function modifyUser(User storage u) internal {
        u.age = 99;
    }

    function callModify() public {
        modifyUser(user);
    }
}
