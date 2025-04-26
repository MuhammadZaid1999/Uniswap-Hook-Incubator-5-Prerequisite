/*
An example of a basic wallet.
    Anyone can send ETH.
    Only the owner can withdraw.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EtherWallet {
    address payable public owner;
    address private owner1;

    constructor() {
        owner = payable(msg.sender);
        owner1 = msg.sender;
    }

    receive() external payable {
        require(msg.sender != owner, "caller is owner");
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount);
    }

    function withdraw1(uint256 _amount) external {
        require(msg.sender == owner, "caller is not owner");
        owner.transfer(_amount);
    }

     function withdraw2(uint256 _amount) external {
        require(msg.sender == owner1, "caller is not owner");
        payable(owner1).transfer(_amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
