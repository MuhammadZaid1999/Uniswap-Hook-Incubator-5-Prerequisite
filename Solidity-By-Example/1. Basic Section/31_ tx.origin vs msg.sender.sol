// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Caller {
    Callee public callee;

    constructor(address _callee) {
        callee = Callee(_callee);
    }

    function callCheck() external {
        callee.checkSender();
    }
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Callee {
    address public owner;

    constructor() {
        owner = msg.sender; // EOA that deployed this contract
    }

    function checkSender() external view returns (address, address, bool, bool) {
        // Returns msg.sender and tx.origin
        return (
            msg.sender,      // Immediate caller (could be contract)
            tx.origin,       // Original EOA that initiated the transaction
            msg.sender == owner, // True if direct call from owner
            tx.origin == owner   // True if tx was initiated by owner
        );
    }
}
