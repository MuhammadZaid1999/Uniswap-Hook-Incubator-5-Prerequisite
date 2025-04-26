/*
When a function is called, the first 4 bytes of calldata specifies which function to call.
This 4 bytes is called a function selector.
Take, for example, this code below. It uses call to execute transfer on a contract at the address addr.

    addr.call(abi.encodeWithSignature("transfer(address,uint256)", 0xSomeAddress, 123))

The first 4 bytes returned from abi.encodeWithSignature(....) is the function selector.
Perhaps you can save a tiny amount of gas if you precompute and inline the function selector in your code?
Here is how the function selector is computed.    


*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Transfers {
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowance;

    function transfer(address _addr, uint256 _amount)
        public  
        payable 
    {
        balances[_addr] += _amount;
    }

     function transfer1(address _addr, uint256 _amount)
        public  
    {
        balances[_addr] += _amount;
    }

    function transferFrom(address _owner, address _spender, uint256 _amount)
        public  
        payable 
    {
        allowance[_owner][_spender] += _amount; 
    }

    function transferFrom1(address _owner, address _spender, uint256 _amount)
        public
    {
        allowance[_owner][_spender] += _amount; 
    }

}

contract FunctionSelector {
    /*
        "transfer(address,uint256)" - 0xa9059cbb
        "transfer1(address,uint256)" - 0x09921939
        "transferFrom(address,address,uint256)" - 0x23b872dd
        "transferFrom1(address,address,uint256)" - 0x35d39414
    */

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowance;

    event Response(bool indexed success, bytes data);

    function getSelector(string calldata _func)
        external
        pure
        returns (bytes4)
    {
        bytes4 selector = bytes4(keccak256(bytes(_func)));
        return selector;

        /*
            --- return directly ---
            return bytes4(keccak256(bytes(_func)));
        */
    }

    function transfer(address _target, bytes4 selector, address _addr, uint256 _amount)
        public  
        payable 
    {
        bytes memory _data = abi.encodeWithSelector(selector, _addr, _amount);
         (bool success, bytes memory data) = _target.call{value: msg.value}(_data);

        emit Response(success, data);
    }

    function transfer1(address _target, bytes4 selector, address _addr, uint256 _amount)
        external
    {
         (bool success, bytes memory data) = _target.delegatecall(
            abi.encodeWithSelector(selector, _addr, _amount)
        );

        emit Response(success, data);
    }

    function transferFrom(address _target, bytes4 selector, address _owner, address _spender, uint256 _amount)
        public  
        payable 
    {
         (bool success, bytes memory data) = _target.call{value: msg.value}(
            abi.encodeWithSelector(selector, _owner, _spender,  _amount)
        );

        emit Response(success, data);
    }

    function transferFrom1(address _target, bytes4 selector, address _owner, address _spender, uint256 _amount)
        external 
    {
        bytes memory _data = abi.encodeWithSelector(selector, _owner, _spender,  _amount);
         (bool success, bytes memory data) = _target.delegatecall(_data);

        emit Response(success, data);
    }

}
