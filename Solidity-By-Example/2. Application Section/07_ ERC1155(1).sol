/*
ERC1155
Example of ERC1155
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract MyMultiToken is ERC1155 {
    using Strings for uint256;
    
    constructor(string memory uri_) ERC1155(uri_){}

    function mint(uint256 id, uint256 value, bytes memory data) external {
        _mint(msg.sender, id, value, data);
    }

    function batchMint(
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external {
        _mintBatch(msg.sender, ids, values, data);
    }

    function burn(uint256 id, uint256 value) external {
        _burn(msg.sender, id, value);
    }

    function batchBurn(uint256[] calldata ids, uint256[] calldata values)
        external
    {
        _burnBatch(msg.sender, ids, values);
    }

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    function supportsInterface() public pure  returns (bytes4, bytes4, bytes4, bytes4) {
        return (type(IERC1155).interfaceId, type(IERC1155MetadataURI).interfaceId, type(ERC165).interfaceId, type(IERC165).interfaceId);
    }

    function uri(uint256 id) public view override returns (string memory) {
        string memory _uri = super.uri(id);
        return bytes(_uri).length > 0 ? string.concat(_uri, id.toString(),".json") : "";
    }

}