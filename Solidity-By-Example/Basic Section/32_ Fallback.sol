/*
fallback is a special function that is executed either when
    a function that does not exist is called or
    Ether is sent directly to a contract but receive() does not exist or msg.data is not empty

To better understand the conditions under which Solidity calls the receive or fallback function, refer to the flowchart below:

                 send Ether
                      |
           msg.data is empty?
                /           \
            yes             no
             |                |
    receive() exists?     fallback()
        /        \
     yes          no
      |            |
  receive()     fallback()

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// fallback has a 2300 gas limit when called by transfer or send.

contract Fallback {
    event Log(string func, uint256 gas);

    // Fallback function must be declared as external.
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        // call (forwards all of the gas)
        emit Log("fallback", gasleft());
    }

    // Receive is a variant of fallback that is triggered when msg.data is empty
    receive() external payable {
        emit Log("receive", gasleft());
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function sendToFallback(address payable _to) external  payable {
        bool success = _to.send(msg.value);
        require(success, "Failed to send Ether");
    }

    function callFallback(address payable _to) external payable {
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}

// fallback can optionally take bytes for input and output

// TestFallbackInputOutput -> FallbackInputOutput -> Counter
contract FallbackInputOutput {
    address immutable target;

    event fallbackCalled();

    constructor(address _target) {
        target = _target;
    }

    fallback(bytes calldata data) external payable returns (bytes memory) {
        emit fallbackCalled();
        (bool ok, bytes memory res) = target.call{value: msg.value}(data);
        require(ok, "call failed");
        return res;
    }
}

contract Counter {
    uint256 public count;

    function get() external view returns (uint256) {
        return count;
    }

    function inc() external returns (uint256) {
        count += 1;
        return count;
    }

    function inc1() external payable returns (uint256) {
        count += 1;
        return count;
    }
}

contract TestFallbackInputOutput {
    event Log(bytes res);

    function test(address _fallback, bytes calldata data) external {
        (bool ok, bytes memory res) = _fallback.call(data);
        require(ok, "call failed");
        emit Log(res);
    }

    function test1(address _fallback, bytes calldata data) external payable {
        (bool ok, bytes memory res) = _fallback.call{value: msg.value}(data);
        require(ok, "call failed");
        emit Log(res);
    }

    function test2(address _fallback) external payable {
        (bool ok, bytes memory res) = _fallback.call{value: msg.value}(abi.encodeCall(Counter.inc1, ()));
        require(ok, "call failed");
        emit Log(res);
    }

    function getTestData() external pure returns (bytes memory, bytes memory, bytes memory) {
        return
            (abi.encodeCall(Counter.get, ()), abi.encodeCall(Counter.inc, ()), abi.encodeCall(Counter.inc1, ()));
    }
}