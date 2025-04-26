/*
An array can have a compile-time fixed size or a dynamic size.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Array {
    // Several ways to initialize an array
    uint256[] public arr;
    uint256[] public arr2 = [1, 2, 3];
    // Fixed sized array, all elements initialize to 0
    uint256[10] public myFixedSizeArr;

    function get(uint256 i) public view returns (uint256) {
        return arr[i];
    }

    // Solidity can return the entire array.
    // But this function should be avoided for
    // arrays that can grow indefinitely in length.
    function getArr() public view returns (uint256[] memory) {
        return arr;
    }

    // Solidity can return the entire array.
    // But this function should be avoided for
    // arrays that can grow indefinitely in length.
    function getMyFixedSizeArr() public view returns (uint256[10] memory) {
        return myFixedSizeArr;
    }

    function push(uint256 i) public {
        // Append to array
        // This will increase the array length by 1.
        arr.push(i);
        arr2.push(i);
        myFixedSizeArr[5] = i;
        // myFixedSizeArr.push(i); ----> TypeError: Member "push" not found or not visible after argument-dependent lookup in uint256[10] storage ref.
    }

    function pop() public {
        // Remove last element from array
        // This will decrease the array length by 1
        arr.pop();
        arr2.pop();
        // myFixedSizeArr.pop(); ----> TypeError: Member "pop" not found or not visible after argument-dependent lookup in uint256[10] storage ref.
    }

    function getLength() public view returns (uint256) {
        return arr.length;
    }

    function getMyFixedSizeArrLength() public view returns (uint256) {
        return myFixedSizeArr.length;
    }

    function remove(uint256 index) public {
        // Delete does not change the array length.
        // It resets the value at index to it's default value,
        // in this case 0
        delete arr[index];
        delete arr2[index];
        delete myFixedSizeArr[index];
    }

     function examples() external pure {
        // create array in memory, only fixed size can be created
        uint256[] memory a = new uint256[](5);
        // a.push(1); ----> TypeError: Member "push" is not available in uint256[] memory outside of storage.
        // a.pop(); ----> TypeError: Member "pop" is not available in uint256[] memory outside of storage.
        a[0] = 1;
        a[1] = 2;
        a[2] = 3;
        a[3] = 4;
        a[4] = 5;

        // create a nested array in memory
        // b = [[1, 2, 3], [4, 5, 6]]
        uint256[][] memory b = new uint256[][](2);
        for (uint256 i = 0; i < b.length; i++) {
            b[i] = new uint256[](3);
        }
        b[0][0] = 1;
        b[0][1] = 2;
        b[0][2] = 3;
        b[1][0] = 4;
        b[1][1] = 5;
        b[1][2] = 6;

        // create array in memory, fixed size can be created
        uint256[1] memory d;
        d[0] = 2;
        // d[1] = 2; ----> TypeError: Out of bounds array access.
    }
}

/*
Examples of removing an array element
Remove an array element by shifting elements from right to left
*/

contract ArrayRemoveByShifting {
    // [1, 2, 3] -- remove(1) --> [1, 3, 3] --> [1, 3]
    // [1, 2, 3, 4, 5, 6] -- remove(2) --> [1, 2, 4, 5, 6, 6] --> [1, 2, 4, 5, 6]
    // [1, 2, 3, 4, 5, 6] -- remove(0) --> [2, 3, 4, 5, 6, 6] --> [2, 3, 4, 5, 6]
    // [1] -- remove(0) --> [1] --> []

    uint256[] public arr;

    function remove(uint256 _index) public {
        require(_index < arr.length, "index out of bounds");

        for (uint256 i = _index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }

    function test() external {
        arr = [1, 2, 3, 4, 5];
        remove(2);
        // [1, 2, 4, 5]
        assert(arr[0] == 1);
        assert(arr[1] == 2);
        assert(arr[2] == 4);
        assert(arr[3] == 5);
        assert(arr.length == 4);

        arr = [1];
        remove(0);
        // []
        assert(arr.length == 0);
    }

    function getLength() public view returns (uint256) {
        return arr.length;
    }
}

/*
Remove an array element by copying last element into to the place to remove
*/

contract ArrayReplaceFromEnd {
    uint256[] public arr;

    // Deleting an element creates a gap in the array.
    // One trick to keep the array compact is to
    // move the last element into the place to delete.
    function remove(uint256 index) public {
        require(index < arr.length, "index out of bounds");
        // Move the last element into the place to delete
        arr[index] = arr[arr.length - 1];
        // Remove the last element
        arr.pop();
    }

    function test() public {
        arr = [1, 2, 3, 4];

        remove(1);
        // [1, 4, 3]
        assert(arr.length == 3);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
        assert(arr[2] == 3);

        remove(2);
        // [1, 4]
        assert(arr.length == 2);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
    }

    function getLength() public view returns (uint256) {
        return arr.length;
    }
}
