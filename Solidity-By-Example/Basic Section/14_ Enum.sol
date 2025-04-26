/*
Solidity supports enums and they are useful to model choice and keep track of state.
Enums can be declared outside of a contract.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./EnumDeclaration.sol";

contract Enum {
    
    // Default value is the first element listed in
    // definition of the type, in this case "Pending"
    Status public status;
    Status[] public status1;

    mapping (uint256 => Status) private statusToIdx;
    mapping (Status => uint256) private statusToIdx1;

    // Returns uint
    // Pending  - 0
    // Shipped  - 1
    // Accepted - 2
    // Rejected - 3
    // Canceled - 4
    function get() public view returns (Status) {
        return status;
    }

    function get1() public view returns (uint8) {
        return uint8(status);
    }

    // Update status by passing uint into input
    function set(Status _status) public {
        status = _status;
        // status1[0] = _status; ----> cannot set on dynamic array
        status1.push(_status);
    }

     function set1(uint8 _status) public {
        status = Status(_status);
        // status1[0] = _status; ----> cannot set on dynamic array
        status1.push(Status(_status));
    }

    // You can update to a specific enum like this
    function cancel() public {
        status = Status.Canceled;
        status1[0] = Status.Canceled;
    }

    // delete resets the enum to its first value, 0
    function reset() public {
        delete status;
        // delete status1[0]; ---> set index value to 0, don't remove index
        delete status1;  // ---> delete whole array, set array length to 0 
    }
}
