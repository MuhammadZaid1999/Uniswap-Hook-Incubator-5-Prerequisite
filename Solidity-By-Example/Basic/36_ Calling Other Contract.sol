/*
Contract can call other contracts in 2 ways.
The easiest way is to just call it, like A.foo(x, y, z).
Another way to call other contracts is to use the low-level call.
This method is not recommended.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Callee {
    uint256 public x;
    uint256 public value;
    address public addr;

    function setX(uint256 _x, address _addr) public returns (uint256, address) {
        x = _x;
        addr = _addr;

        return (x, addr);
    }

    function setXandSendEther(uint256 _x)
        public
        payable
        returns (uint256, uint256, address)
    {
        x = _x;
        addr = msg.sender;
        value = msg.value;

        return (x, value, addr);
    }
}

contract Caller {
    function setX(Callee _callee, uint256 _x) public {
        (uint256 x, address addr) = _callee.setX(_x, msg.sender);
    }

    function setXFromAddress(address _addr, uint256 _x) public {
        Callee callee = Callee(_addr);
        callee.setX(_x, msg.sender);
    }

    function setXFromAddress2(address _callee, uint256 _x) public {
        Callee(_callee).setX(_x, msg.sender);
    }

    function setXandSendEther(Callee _callee, uint256 _x) public payable {
        (uint256 x, uint256 value, address addr) =
            _callee.setXandSendEther{value: msg.value}(_x);
    }

    function setXandSendEtherfromAddress(address _callee, uint256 _x) public payable {
        (uint256 x, uint256 value, address addr) = Callee(_callee).setXandSendEther{value: msg.value}(_x);
    }

    function setXandSendEtherfromAddress2(address _callee, uint256 _x) public payable {
        Callee callee = Callee(_callee);
        callee.setXandSendEther{value: msg.value}(_x);
    }
}
