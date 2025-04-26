/*
How to send Ether?
You can send Ether to other contracts by
    transfer (2300 gas, throws error)
    send (2300 gas, returns bool)
    call (forward all gas or set gas, returns bool)

How to receive Ether?
A contract receiving Ether must have at least one of the functions below
    receive() external payable
    fallback() external payable
receive() is called if msg.data is empty, otherwise fallback() is called.

Which method should you use?
call in combination with re-entrancy guard is the recommended method to use after December 2019.
Guard against re-entrancy by
    making all state changes before calling other contracts
    using re-entrancy guard modifier
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {SafeTransferLib} from "github.com/Vectorized/solady/blob/main/src/utils/SafeTransferLib.sol";
import "hardhat/console.sol";

contract ReceiveEther {
    /*
    Which function is called, fallback() or receive()?

           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
    receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */

    mapping (address => uint256) public balances;
    event ReceivedEther(uint256 indexed amount, address indexed _address, bytes indexed data);

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        console.log("----- Call Received -----");
        address sender = msg.sender; 
        balances[sender] += msg.value;
        emit ReceivedEther(msg.value, sender, "");
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        console.log("----- Call Fallback -----");
        // bytes memory data = msg.data; ----> we can also use this
        address sender = msg.sender; 
        balances[sender] += msg.value;
        emit ReceivedEther(msg.value, sender, msg.data);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract SendEther {
    function sendViaTransfer(address payable _to) public payable {
        // This function is no longer recommended for sending Ether.
        _to.transfer(msg.value);
    }

    function sendViaTransfer1(address _to) public payable {
        // This function is no longer recommended for sending Ether.
        uint256 amount = 5 wei;
        payable(_to).transfer(amount);
    }

    function sendViaSend(address payable _to) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaSend1(address _to) public payable {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        uint256 amount = 5 gwei;
        bool sent = payable(_to).send(amount);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function sendViaCall1(address _to) public payable {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
         uint256 amount = 0.2 gwei;
        (bool sent, bytes memory data) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // This is 0.36% more gas-efficient per call and is more concise as well
    function sendViaSolady(address payable _to) public payable {
        // Reverts with ETHTransferFailed error
        // this is the most gas-efficient method to use
        SafeTransferLib.safeTransferETH(_to, msg.value);
    }

    // This is 0.36% more gas-efficient per call and is more concise as well
    function sendViaSolady1(address _to) public payable {
        // Reverts with ETHTransferFailed error
        // this is the most gas-efficient method to use
        uint256 amount = 0.1 ether;
        SafeTransferLib.safeTransferETH(_to, amount);
    }
}