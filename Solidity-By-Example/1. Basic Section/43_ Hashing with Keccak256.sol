/*
keccak256 computes the Keccak-256 hash of the input.
Some use cases are:
    Creating a deterministic unique ID from an input
    Commit-Reveal scheme
    Compact cryptographic signature (by signing the hash instead of a larger input)

Solidity provides two methods for encoding data:
    abi.encode:
        Encodes data into bytes with padding
        Preserves all data information
        Safer when dealing with dynamic types
        Produces a longer output due to padding
    abi.encodePacked:
        Performs packed encoding (compressed)
        Produces a shorter output than abi.encode
        More gas efficient
        Risk of hash collisions with dynamic types (collision function)
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HashFunction {
    function hash(string memory _text, uint256 _num, address _addr)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_text, _num, _addr));
    }

    function hash1(string memory _text, uint256 _num, address _addr)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_text, _num, _addr));
    }

    function hash1(string memory _text, uint256 _num, address _addr, bytes3 _byte)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(_text, _num, _addr, _byte));
    }

     function transfer(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // Typo is not checked - "transfer(address, uint)"
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function transfer(string memory funcSignature, address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        bytes memory args = abi.encode(to, amount);
        return dynamicCall(funcSignature, args);
    }

    function transfer1(bytes4 selector, address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        bytes memory args = abi.encode(to, amount);
        return dynamicCall1(selector, args);
    }

    function dynamicCall(string memory funcSignature, bytes memory args) internal pure returns (bytes memory data){
        bytes4 selector = bytes4(keccak256(bytes(funcSignature)));
        data = abi.encodePacked(selector, args);
    }

    function dynamicCall1(bytes4 selector, bytes memory args) internal pure returns (bytes memory data){
        data = abi.encodePacked(selector, args);
    }

    // Example of hash collision
    // Hash collision can occur when you pass more than one dynamic data type
    // to abi.encodePacked. In such case, you should use abi.encode instead.
    function collision(string memory _text, string memory _anotherText)
        public
        pure
        returns (bytes32)
    {
        // encodePacked(AAA, BBB) -> AAABBB
        // encodePacked(AA, ABBB) -> AAABBB
        return keccak256(abi.encodePacked(_text, _anotherText));
    }
}

contract GuessTheMagicWord {
    bytes32 public answer =
        0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;

    // Magic word is "Solidity"
    function guess(string memory _word) public view returns (bool) {
        return keccak256(abi.encodePacked(_word)) == answer;
    }
}

