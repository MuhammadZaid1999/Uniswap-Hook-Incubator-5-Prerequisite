/*
ERC721
Example of ERC721
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {

    constructor(string memory name, string memory symbol) 
        ERC721(name, symbol) {}

    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function burn(uint256 id) external {
        require(msg.sender == ownerOf(id), "not owner");
        _burn(id);
    }
}
