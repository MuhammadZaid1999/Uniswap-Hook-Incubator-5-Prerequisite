/*
Create your own ERC20 token
Using Open Zeppelin it's really easy to create your own ERC20 token.
Here is an example
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    uint8 private immutable decimal;

    constructor(string memory _name, string memory _symbol, uint8 _decimals)
        ERC20(_name, _symbol)
    {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        decimal = _decimals;
        _mint(msg.sender, 100 * 10 ** uint256(_decimals));
    }

    function decimals() public view override returns (uint8) {
        return decimal;
    }

    function name() public pure override returns (string memory) {
        return "Zaid";
    }

    function symbol() public pure override returns (string memory) {
        return "MZ";
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

     function burn(address to, uint256 amount) external {
        _burn(to, amount);
    }

}
