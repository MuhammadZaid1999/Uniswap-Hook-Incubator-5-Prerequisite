/*
Transactions are paid with ether.
Similar to how one dollar is equal to 100 cents, one ether is equal to 1018 wei.
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EtherUnits {
    uint256 public oneWei = 1 wei;
    // 1 wei is equal to 1
    bool public isOneWei = (oneWei == 1);

    uint256 public oneGwei = 1 gwei;
    // 1 gwei is equal to 10^9 wei
    bool public isOneGwei = (oneGwei == 1e9);
    bool public isOneGwei1 = (oneGwei == 10**9);

    uint256 public oneEther = 1 ether;
    // 1 ether is equal to 10^18 wei
    bool public isOneEther = (oneEther == 1e18);
    bool public isOneEther1 = (oneEther == 10**18);

    function isOneEth() public view returns (bool) {
        return oneEther == 1e18;
    }

    function _isOneWei() public pure returns (bool) {
        return 1 wei == 1;
    }
}
