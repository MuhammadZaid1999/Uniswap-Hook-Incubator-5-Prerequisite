// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external payable;
}

contract Token {
    function transfer(address, uint256) external {}
    function transferFrom(address, address, uint256) external payable {}
}

contract AbiEncode {
    function test(address _contract, bytes calldata data) external {
        (bool ok,) = _contract.call(data);
        require(ok, "call failed");
    }

    function test1(address _contract, bytes calldata data) external payable {
        (bool ok,) = _contract.call{value: msg.value}(data);
        require(ok, "call failed");
    }

    function encodeWithSignature(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // Typo is not checked - "transfer(address, uint)"
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function encodeWithSignature1(string memory func, address from, address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // Typo is not checked - "transfer(address, uint)"
        return abi.encodeWithSignature(func, from, to, amount);
    }

    function encodeWithSelector(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // Type is not checked - (IERC20.transfer.selector, true, amount)
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    function encodeWithSelector1(address from, address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // Type is not checked - (IERC20.transfer.selector, true, amount)
        return abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, amount);
    }

    function encodeCall(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // Typo and type errors will not compile
        return abi.encodeCall(Token.transfer, (to, amount));
    }

    function encodeCall1(address from, address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // Typo and type errors will not compile
        return abi.encodeCall(IERC20.transferFrom, (from, to, amount));
    }
}
