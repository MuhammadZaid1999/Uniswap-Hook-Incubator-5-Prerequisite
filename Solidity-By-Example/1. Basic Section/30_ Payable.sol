/*
Functions and addresses declared payable can receive ether into the contract.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Payable {
    // Payable address can send Ether via transfer or send
    address payable public owner;
    address public owner1;

    // Payable constructor can receive Ether
    constructor() payable {
        owner = payable(msg.sender);
        owner1 = msg.sender;
    }

    // Function to deposit Ether into this contract.
    // Call this function along with some Ether.
    // The balance of this contract will be automatically updated.
    function deposit() public payable {}

    // Call this function along with some Ether.
    // The function will throw an error since this function is not payable.
    function notPayable() public {}

    // Function to withdraw all Ether from this contract.
    function withdraw() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to withdraw all Ether from this contract.
    function withdraw1() public {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;

        // send all Ether to owner
        (bool success,) = owner1.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

      // Function to withdraw all Ether from this contract.
    function withdraw2(uint256 amount) public {
        // send all Ether to owner
        (bool success,) = payable(owner1).call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint256 _amount) public {
        // Note that "to" is declared as payable
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer1(address _to, uint256 _amount) public {
        // Note that "to" is declared as payable
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    // Function to transfer Ether from this contract to address from input
    function transfer2(address _to, uint256 _amount) public {
        // Note that "to" is declared as payable
        (bool success,) = payable(_to).call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}
