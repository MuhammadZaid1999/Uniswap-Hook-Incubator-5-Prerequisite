/*
In Solidity, the bytes data type is used to handle raw binary data. 
It comes in two primary forms: fixed-size (bytes1 to bytes32) and dynamic-size (bytes). 
Understanding their differences, use cases, and behaviors is crucial for efficient smart contract development.​

Fixed-Size Bytes (bytes1 to bytes32)
    Definition: Fixed-size byte arrays where bytesN represents an array of N bytes, with N ranging from 1 to 32.​
    Usage: Ideal for scenarios where the data size is known and constant, such as storing hashes (bytes32), addresses (bytes20), or specific identifiers.​
    Characteristics:
        Storage Efficiency: Occupies a single 32-byte storage slot, making it gas-efficient.
        Bitwise Operations: Supports operations like AND (&), OR (|), XOR (^), NOT (~), left shift (<<), and right shift (>>).
        Access: Allows read access to individual bytes via indexing (e.g., myBytes[0]).
        Length: The .length property returns the fixed size N.​
*/

contract FixedBytes {
    bytes4 public example = 0x12345678;
    bytes1 firstByte = example[0]; // 0x12

    bytes4 public constant number = 0x12340C02;
    bytes4 public number1 = 0x12340C02;  

    /*
        Fixed-size byte arrays have a specified length, ranging from 1 to 32 bytes. 
        The notation “bytesN” is used to represent these arrays, where “N” is an integer representing the length of the array. 
        These arrays are useful when you know the exact size of the data you are working with.
    */
    bytes1 public fixedData;
    bytes2 public fixedData1; 
    bytes3 public fixedData2;
    bytes6 public fixedData3;
    bytes10 public fixedData4;
    bytes20 public fixedData5;
    bytes24 public fixedData6;
    bytes32 public fixedData7;

    function getIndividualBytes() public pure returns (bytes1, bytes1, bytes1, bytes1) { 
        bytes1 byte1 = bytes1(number[0]); 
        bytes1 byte2 = number[1]; 
        bytes1 byte3 = number[2]; 
        bytes1 byte4 = bytes1(number[3]); 
  
        return (byte1, byte2, byte3, byte4); 
    } 

    function getIndividualBytes1() public pure returns (bytes1, bytes1) { 
        bytes1 byte3 = bytes1(number[2]); 
        bytes1 byte4 = byte3[0];
        bytes1 byte5 = byte3;
        return (byte4, byte5); 
    }  

     // Set the fixed-size byte array 
    function setFixedData(
        bytes1 _data, 
        bytes2 _data1,  
        bytes6 _data3, 
        bytes10 _data4, 
        bytes24 _data6, 
        bytes32 _data7
        ) public { 
        fixedData = _data; 
        fixedData1 = _data1; 
        fixedData2 = 0x1234e6; 
        fixedData3 = _data3; 
        fixedData4 = _data4; 
        fixedData5 = hex"1234E6c6dEaA11200233"; 
        fixedData6 = _data6; 
        fixedData7 = _data7; 
    } 
  
    // Get the length of the fixed-size byte array 
    function getFixedDataLength() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) { 
        return (
            fixedData.length,
            fixedData1.length,
            fixedData2.length,
            fixedData3.length,
            fixedData4.length,
            fixedData5.length,
            fixedData6.length,
            fixedData7.length
        );
            // Always returns 32 for bytes32 
    }  

}

/*
Dynamic-Size Bytes (bytes)
    Definition: A dynamically-sized byte array, suitable for handling variable-length binary data.​
    Usage: Commonly used when the size of the data isn't known at compile time, such as for arbitrary data blobs or when interfacing with external systems.​
    Characteristics:
        Flexibility: Can grow or shrink in size during execution.
        Operations: Supports methods like .push(), .pop(), and .length to manipulate the array.
        Storage Considerations: While flexible, dynamic arrays can be more gas-intensive than fixed-size arrays due to additional storage operations.
*/
contract DynamicBytes{
    bytes public dynamicBytes = new bytes(5);
    bytes public dynamicData; 

    function setBytes() public returns(uint){
        dynamicBytes[0] = 0x01;
        dynamicBytes.push(0x02);
        uint length = dynamicBytes.length; // 6
        return length;
    }
  
    // Set the dynamic byte array 
    function setDynamicData(bytes calldata _data) public { 
        dynamicData = _data; 
    } 

    function popDynamicData() public { 
        dynamicData.pop(); 
        dynamicBytes.pop();
    } 
  
    // Get the length of the dynamic byte array 
    function getDynamicDataLength() public view returns (uint256) { 
        return dynamicData.length; 
    } 

    function getDynamicByteLength() public view returns (uint256) { 
        return dynamicBytes.length; 
    } 

}

/*
Array of Bytes = a little difference
In Solidity, an array of bytes is used to store a dynamic sequence of bytes. 
This can be useful for storing data that does not have a fixed size or structure, such as raw data or arbitrary messages.
An array of bytes is declared using the syntax bytes or bytesX, where X is a number indicating the size of the array. 
The maximum size of the array is 2^256-1.
*/

contract ByteArray { 
    bytes3[] public b = new bytes3[](2);
    bytes2[] public b1;

    bytes public byteArray; // declare an empty array of bytes
    bytes1 public byte1Array; // declare an array of 1 byte
    bytes2 public byte2Array; // declare an array of 2 bytes
    bytes32 public byte32Array; // declare an array of 32 bytes

    function concatenate(bytes memory a, bytes memory b) public pure returns (bytes memory) { 
        bytes memory result = new bytes(a.length + b.length); 
        uint i; 
        uint j = 0; 
        for (i = 0; i < a.length; i++) { 
            result[j++] = a[i]; 
        } 
        for (i = 0; i < b.length; i++) { 
            result[j++] = b[i]; 
        } 
        return result; 
    } 

    function concatenate1() public pure returns (bytes memory, bytes4 a) { 
        bytes memory byteArray1 = hex"deadbeef";
        a = hex"cd";
        return (byteArray1, a);
    } 

    function concatenate2() public { 
        byteArray = hex"d3EA12EaCd";
        byte1Array = hex"1C";
        byte2Array = hex"1e";
        byte32Array = hex"1eDaE4";
    } 

    function setB() public { 
        bytes3 byteArray1 = hex"1234";
        b[0] = byteArray1;
        b.push(byteArray1);
    } 

    function setB1() public { 
        bytes2 byteArray1 = hex"dead";
        b1.push(byteArray1);
    } 

    function setPop() public { 
        b.pop();
        b1.pop();
    } 
} 

/*
Bytes as Function Arguments
You can use bytes as function arguments in Solidity. When you pass a bytes argument, 
you can manipulate and work with the byte data within the function.
*/

contract BytesFunctionExample { 
    // Prints the length of a bytes array 
    function printBytesLength(bytes calldata data) public pure returns (uint) { 
        return data.length; 
    } 
}

/*
Conversion between addresses and bytes20
An Ethereum address is 20 bytes long, and you can convert it to a bytes20 type or vice versa. 
To convert an address to bytes20, you can use an explicit typecast.
*/

contract AddressBytes20Conversion { 
	// Converts an Ethereum address to bytes20 
	function addressToBytes20(address addr) public pure returns (bytes20) { 
		return bytes20(addr); 
	} 

	// Converts a bytes20 value to an Ethereum address 
	function bytes20ToAddress(bytes20 bytes20Addr) public pure returns (address) { 
		return address(bytes20Addr); 
	} 
} 

/*
Conversion Between string and bytes
    From string to bytes: Use bytes(someString) to convert a string to its byte representation.​
    From bytes to string: Use string(someBytes) to convert bytes back to a string.​

    Considerations:
        Ensure that the byte data represents valid UTF-8 sequences when converting to string.
        Be cautious of padding and null bytes (0x00) when dealing with fixed-size byte arrays.​
*/

contract StringBytesConversion { 
	// Converts an String to bytes value
	function a1(string calldata a) public pure returns (bytes memory) { 
		return bytes(a); 
	} 

	// Converts a bytes value to String
	function b1(bytes memory b) public pure returns (string memory) { 
		return string(b); 
	} 

	// Converts a bytes20 value to an Ethereum address 
	function c1(bytes4 b) public pure returns (uint32) { 
		return uint32(b); 
	} 

    // Converts a bytes20 value to an Ethereum address 
	function d1(uint32 b) public pure returns (bytes4) { 
		return bytes4(b); 
	} 

    function e1(bytes10 b) public pure returns (uint80) { 
		return uint80(b); 
	} 

    function e2() public pure returns (uint80) { 
		return uint80(bytes10(hex"34cdA3")); 
	} 

    function f1(uint80 b) public pure returns (bytes10) { 
		return bytes10(b); 
	} 

    // Converts a bytes20 value to an Ethereum address 
	function g1(bytes32 b) public pure returns (uint) { 
		return uint(b); 
	} 

    // Converts a bytes20 value to an Ethereum address 
	function h1(uint b) public pure returns (bytes32) { 
		return bytes32(b); 
	} 
} 

/*
Advanced Operations with Bytes
Aside from the basic operations, you can perform more advanced operations with byte arrays. these are a few examples:
    Concatenating two-byte arrays
    Comparing two-byte arrays for equality
*/

contract AdvancedBytesOperations { 
	// Concatenates two byte arrays 
	function concat(bytes calldata a, bytes calldata b) public pure returns (bytes memory) { 
		bytes memory result = new bytes(a.length + b.length); 
		for (uint i = 0; i < a.length; i++) { 
			result[i] = a[i]; 
		} 
		for (uint j = 0; j < b.length; j++) { 
			result[a.length + j] = b[j]; 
		} 
		return result; 
	} 

	// Compares two byte arrays for equality 
	function equalBytes(bytes calldata a, bytes calldata b) public pure returns (bool) { 
		if (a.length != b.length) { 
			return false; 
		} 
		for (uint i = 0; i < a.length; i++) { 
			if (a[i] != b[i]) { 
				return false; 
			} 
		} 
		return true; 
	} 
} 


/*
Best Practices and Considerations
    Use Fixed-Size Bytes When Possible: If the size of the data is known and constant, prefer bytesN types for gas efficiency.​
    Avoid byte[]: Using byte[] is less efficient due to padding and should generally be replaced with bytes or bytesN.​
    Be Mindful of Padding: When assigning shorter data to a fixed-size byte array, Solidity pads the remaining bytes with zeros. This can affect comparisons and hashing.​
    Gas Costs: Dynamic arrays (bytes) can be more expensive in terms of gas, especially when resizing or performing multiple write operations.​
*/