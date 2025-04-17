/*
delegatecall is a low level function similar to call.
When contract A executes delegatecall to contract B, B's code is executed
with contract A's storage, msg.sender and msg.value
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// NOTE: Deploy this contract first
contract B {
    // NOTE: storage layout must be the same as contract A
    uint256 public num;
    address public sender;
    uint256 public value;
    uint256 public count;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }

    function setCount() public returns (uint256){
        return count++;
    }

    function getCount() public view returns (uint256){
        return count;
    }
}

contract A {
    uint256 public num;
    address public sender;
    uint256 public value;
    uint256 public count;

    event DelegateResponse(bool success, bytes data);
    event CallResponse(bool success, bytes data);

    // Function using call
    function setVarsCall(address _contract, uint256 _num) public payable {
        // B's storage is set; A's storage is not modified.
        (bool success, bytes memory data) = _contract.call{value: msg.value}(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );

        emit CallResponse(success, data);
    }

    // Function using delegatecall
    function setVarsDelegateCall(address _contract, uint256 _num)
        public
        payable
    {
        // A's storage is set; B's storage is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );

        emit DelegateResponse(success, data);
    }

      // Function using delegatecall
    function setVarsDelegateCall1(address _contract, string calldata _data, uint256 _num)
        public
        payable
    {
        // A's storage is set; B's storage is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature(_data, _num)
        );

        emit DelegateResponse(success, data);
    }

     // Function using call
    function setCountCall(address _contract, bytes memory _data) public {
        // B's storage is set; A's storage is not modified.
        (bool success, bytes memory data) = _contract.call(_data);

        emit CallResponse(success, data);
    }

     // Function using delegatecall
    function setCountDelegateCall(address _contract)
        public
    {
        // A's storage is set; B's storage is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setCount()")
        );

        emit DelegateResponse(success, data);
    }

     // Function using delegatecall
    function setCountDelegateCall1(address _contract, bytes memory _data) public {
        // A's storage is set; B's storage is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(_data);

        emit DelegateResponse(success, data);
    }

    // only for functions with empty params - pass string function signature
    function getSelector1(string calldata _func)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSignature(_func);
    }
}
