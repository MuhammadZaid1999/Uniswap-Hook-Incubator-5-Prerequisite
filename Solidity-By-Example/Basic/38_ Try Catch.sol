/*
try / catch can only catch errors from external function calls and contract creation.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// External contract used for try / catch examples
contract Foo {
    address public owner;

    constructor(address _owner) {
        require(_owner != address(0), "invalid address");
        assert(_owner != 0x0000000000000000000000000000000000000001);
        owner = _owner;
    }

    function myFunc(uint256 x) public pure returns (string memory) {
        require(x != 0, "require failed");
        return "my func was called";
    }

    function myFunc1(address _add) public returns (address) {
        if(owner != msg.sender){
            revert("invalid owner");    
        }
        owner = _add;
        return owner;
    }

    function myFunc2(address _add) public view returns (address) {
        assert(_add == owner);
        return owner;
    }
}

contract Bar {
    event Log(string message);
    event LogBytes(bytes data);

    Foo public foo;

    constructor() {
        // This Foo contract is used for example of try catch with external call
        foo = new Foo(msg.sender);
    }

    // Example of try / catch with external call
    // tryCatchExternalCall(0) => Log("external call failed")
    // tryCatchExternalCall(1) => Log("my func was called")
    function tryCatchExternalCall(uint256 _i) public {
        try foo.myFunc(_i) returns (string memory result) {
            emit Log(result);
        } catch {
            emit Log("external call failed");
        }
    }

    function tryCatchExternalCall1(uint256 _i) public view returns (string memory){
        try foo.myFunc(_i) returns (string memory result) {
            return result;
        } catch(bytes memory reason) {
            // catch failing assert()
            return string(reason);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            return reason;
        } 
    }

    function tryCatchExternalCall2(uint256 _i) public view returns (string memory){
        string memory result;
        try foo.myFunc(_i) returns (string memory _result) {
            result = _result;
        } catch(bytes memory reason) {
            // catch failing assert()
            result = string(reason);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            result = reason;
        } 
        return result;
    }

    function tryCatchExternalCall3(address _i) public returns (address){
        address result;
        try foo.myFunc1(_i) returns (address _result) {
            result = _result;
        } catch(bytes memory reason) {
            // catch failing assert()
            emit LogBytes(reason);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            emit Log(reason);
        } 
        return result;
    }

    function tryCatchExternalCall4(address _i) public  {
        address result;
        try foo.myFunc1(_i) returns (address _result){
            result = _result;
        } catch(bytes memory reason) {
            // catch failing assert()
            emit LogBytes(reason);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            emit Log(reason);
        } 
    }

    function tryCatchExternalCall5(address _i) public  {
        try foo.myFunc1(_i) {
            // result = _result;
        } catch(bytes memory reason) {
            // catch failing assert()
            emit LogBytes(reason);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            emit Log(reason);
        } 
    }

    function tryCatchExternalCall6(address _i) public view returns (address){
        try foo.myFunc2(_i) returns (address result) {
            return result;
        } catch(bytes memory reason) {
            // catch failing assert(
            return address(0);
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            return address(0);
        } 
    }

    function tryCatchExternalCall7(address _i) public view returns (address addr, string memory reason, bytes memory reason1){
        try foo.myFunc2(_i) returns (address result) {
            addr = result;
        } catch(bytes memory _reason) {
            // catch failing assert(
            reason1 = _reason;
        } catch Error(string memory _reason) {
            // catch failing revert() and require()
            reason = _reason;
        } 
    }

    // Example of try / catch with contract creation
    // tryCatchNewContract(0x0000000000000000000000000000000000000000) => Log("invalid address")
    // tryCatchNewContract(0x0000000000000000000000000000000000000001) => LogBytes("")
    // tryCatchNewContract(0x0000000000000000000000000000000000000002) => Log("Foo created")
    function tryCatchNewContract(address _owner) public {
        try new Foo(_owner) returns (Foo foo) {
            // you can use variable foo here
            emit Log("Foo created");
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            emit Log(reason);
        } catch (bytes memory reason) {
            // catch failing assert()
            emit LogBytes(reason);
        }
    }

    function tryCatchNewContract1(address _owner) public {
        try new Foo(_owner) {
            // you can use variable foo here
            emit Log("Foo created");
        } catch {
            emit Log("Foo not created");
        }
    }

}
