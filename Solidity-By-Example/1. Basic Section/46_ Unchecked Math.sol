/*
Overflow and underflow of numbers in Solidity 0.8 throw an error. This can be disabled by using unchecked.
Disabling overflow / underflow check saves gas.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract UncheckedMath {
    function add(uint256 x, uint256 y) external pure returns (uint256) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        unchecked {
            return x + y;
        }
    }

    function add(uint8 x, uint8 y) external pure returns (uint8) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        unchecked {
            return x + y;
        }
    }

    function add(uint16 x, uint16 y) external pure returns (uint16) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        return x + y;
    }

    function add(uint64 x, uint64 y) external pure returns (uint64) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        return x + y;
    }

    function sub(uint256 x, uint256 y) external pure returns (uint256) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        unchecked {
            return x - y;
        }
    }

    function sub(uint32 x, uint32 y) external pure returns (uint32) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        unchecked {
            return x - y;
        }
    }

    function sub(uint64 x, uint64 y) external pure returns (uint64) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        return x - y;
    }

    function sub(uint128 x, uint128 y) external pure returns (uint128) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        return x - y;
    }

    function sumOfCubes(uint256 x, uint256 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        unchecked {
            uint256 x3 = x * x * x;
            uint256 y3 = y * y * y;

            return x3 + y3;
        }
    }

    function sumOfCubes(uint8 x, uint8 y) external pure returns (uint8) {
        // Wrap complex math logic inside unchecked
        unchecked {
            uint8 x3 = x * x * x;
            uint8 y3 = y * y * y;

            return x3 + y3;
        }
    }

    function sumOfCubes(uint32 x, uint32 y) external pure returns (uint32) {
        // Wrap complex math logic inside unchecked
        uint32 x3 = x * x * x;
        uint32 y3 = y * y * y;

        return x3 + y3;
    }

    function sumOfCubes(uint64 x, uint64 y) external pure returns (uint64) {
        // Wrap complex math logic inside unchecked
        unchecked {
            uint64 x3 = x * x * x;
            uint64 y3 = y * y * y;

            return x3 + y3;
        }
    }

    function sumOfCubes(uint128 x, uint128 y) external pure returns (uint128) {
        // Wrap complex math logic inside unchecked
        uint128 x3 = x * x * x;
        uint128 y3 = y * y * y;

        return x3 + y3;
    }

    function power(uint256 x, uint256 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        unchecked {
            return x * 10 ** y;
        }
    }

    function power(uint8 x, uint8 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        unchecked {
            return x * 10 ** y;
        }
    }

    function power(uint32 x, uint32 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        return x * 10 ** y;
    }

    function power(uint64 x, uint64 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        return x * 10 ** y;
    }

    function power(uint128 x, uint128 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        return x * 10 ** y;
    }
}


contract UncheckedMath1 {
    function add(int256 x, int256 y) external pure returns (int256) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        unchecked {
            return x + y;
        }
    }

    function add(int8 x, int8 y) external pure returns (int8) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        unchecked {
            return x + y;
        }
    }

    function add(int16 x, int16 y) external pure returns (int16) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        return x + y;
    }

    function add(int64 x, int64 y) external pure returns (int64) {
        // 22291 gas
        // return x + y;

        // 22103 gas
        return x + y;
    }

    function sub(int256 x, int256 y) external pure returns (int256) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        unchecked {
            return x - y;
        }
    }

    function sub(int32 x, int32 y) external pure returns (int32) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        unchecked {
            return x - y;
        }
    }

    function sub(int64 x, int64 y) external pure returns (int64) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        return x - y;
    }

    function sub(int128 x, int128 y) external pure returns (int128) {
        // 22329 gas
        // return x - y;

        // 22147 gas
        return x - y;
    }

    function sumOfCubes(int256 x, int256 y) external pure returns (int256) {
        // Wrap complex math logic inside unchecked
        unchecked {
            int256 x3 = x * x * x;
            int256 y3 = y * y * y;

            return x3 + y3;
        }
    }

    function sumOfCubes(int8 x, int8 y) external pure returns (int8) {
        // Wrap complex math logic inside unchecked
        unchecked {
            int8 x3 = x * x * x;
            int8 y3 = y * y * y;

            return x3 + y3;
        }
    }

    function sumOfCubes(int32 x, int32 y) external pure returns (int32) {
        // Wrap complex math logic inside unchecked
        int32 x3 = x * x * x;
        int32 y3 = y * y * y;

        return x3 + y3;
    }

    function sumOfCubes(int64 x, int64 y) external pure returns (int64) {
        // Wrap complex math logic inside unchecked
        unchecked {
            int64 x3 = x * x * x;
            int64 y3 = y * y * y;

            return x3 + y3;
        }
    }

    function sumOfCubes(int128 x, int128 y) external pure returns (int128) {
        // Wrap complex math logic inside unchecked
        int128 x3 = x * x * x;
        int128 y3 = y * y * y;

        return x3 + y3;
    }

     function power(int256 x, int256 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        unchecked {
            return uint(x) * 10 ** uint(y);
        }
    }

    function power(int8 x, int8 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        unchecked {
            uint256 z =  uint8(x) * 10 ** uint8(y);
            return z;
        }
    }

    function power(int32 x, int32 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        uint256 z =  uint32(x) * 10 ** uint32(y);
        return z;
    }

    function power(int64 x, int64 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        return uint64(x) * 10 ** uint64(y);
    }

    function power(int128 x, int128 y) external pure returns (uint256) {
        // Wrap complex math logic inside unchecked
        return uint128(x) * 10 ** uint128(y);
    }
}
