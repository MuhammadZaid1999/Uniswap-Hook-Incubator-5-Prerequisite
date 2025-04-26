/*
call is a low level function to interact with other contracts.
This is the recommended method to use when you're just sending Ether via calling the fallback function.
However it is not the recommended way to call existing functions.

Few reasons why low-level call is not recommended
    Reverts are not bubbled up
    Type checks are bypassed
    Function existence checks are omitted
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Receiver {
    uint x = 5;

    event Received(address caller, uint256 amount, string message);

    receive() external payable {
        emit Received(msg.sender, msg.value, "Receive was called");
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
    }

    function foo(string memory _message, uint256 _x)
        public
        payable
        returns (uint256)
    {
        emit Received(msg.sender, msg.value, _message);

        return _x + 1;
    }

    function foo1()
        public
        returns (uint256)
    {
        emit Received(msg.sender, 0, "");

        return 1;
    }

    function foo2()
        public
        view 
        returns (uint256)
    {
        return x + 1;
    }
}

contract Caller {
    event Response(bool success, bytes data);

    // Let's imagine that contract Caller does not have the source code for the
    // contract Receiver, but we do know the address of contract Receiver and the function to call.
    function testCallFoo(address _addr) public payable {
        // You can send ether and specify a custom gas amount
        (bool success, bytes memory data) = _addr.call{
            value: msg.value,
            gas: 5000
        }(abi.encodeWithSignature("foo(string,uint256)", "call foo", 123));

        emit Response(success, data);
    }

    function testCallFoo1(address _addr) public {
        // You can send ether and specify a custom gas amount
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("foo1()")
        );

        emit Response(success, data);
    }

    function testAllFoo(address _addr, bytes memory _data) public payable {
        // You can send ether and specify a custom gas amount
        (bool success, bytes memory data) = _addr.call(_data);

        emit Response(success, data);
    }

    // Calling a function that does not exist triggers the fallback function.
    function testCallDoesNotExist(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value}(
            abi.encodeWithSignature("doesNotExist()")
        );

        emit Response(success, data);
    }

    function getEncodeFoo1() external pure returns (bytes memory) {
        return abi.encodeCall(Receiver.foo1, ());
    }

    function _getEncodeFoo1() public pure returns (bytes memory) {
        return abi.encodeWithSignature("foo1()");
    }

    function getEncodeFoo2() external pure returns (bytes memory) {
        return abi.encodeCall(Receiver.foo2, ());
    }

    function getEncodeFoo() external pure returns (bytes memory) {
        return abi.encodeWithSignature("foo(string,uint256)", "call foo", 123);
    }
}
