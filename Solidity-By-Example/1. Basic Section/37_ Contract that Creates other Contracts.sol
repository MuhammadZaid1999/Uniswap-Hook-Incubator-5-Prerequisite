/*
Contracts can be created by other contracts using the new keyword. Since 0.8.0, new keyword supports create2 feature by specifying salt options.

​In Solidity, the salt keyword is used in conjunction with the CREATE2 opcode to enable deterministic smart contract deployments. This feature allows developers to precompute the address of a contract before it's deployed, which is particularly useful in scenarios like upgradeable contracts, counterfactual deployments, and factory patterns.

How salt Works with CREATE2:
When deploying a contract using CREATE2, the resulting contract address is computed based on the following parameters:​
    The address of the deploying contract
    A user-specified salt value (a bytes32 value)
    The hash of the contract's creation bytecode
    The constructor arguments

The formula for computing the contract address is:​
    address = keccak256(0xff ++ deployingAddress ++ salt ++ keccak256(init_code))[12:]

Benefits of Using salt with CREATE2:
    Predictable Addresses: You can compute the address of a contract before deployment, which is useful for creating interactions between contracts that are yet to be deployed.​
    Upgradeability: By deploying a new contract with the same salt and creation code after self-destructing the previous one, you can effectively upgrade contracts at the same address.​
    Enhanced Security: Using a unique salt adds an additional layer of security, making it more challenging for attackers to predict contract addresses.

Important Considerations:
    Uniqueness of salt: Ensure that the combination of the deploying address, salt, and contract bytecode is unique to prevent address collisions.​
    Immutability of Deployed Code: Once a contract is deployed at a specific address using CREATE2, deploying another contract with the same parameters will fail unless the original contract is removed (e.g., via selfdestruct).​
    Constructor Arguments: The constructor arguments affect the contract's creation bytecode. Changing these arguments will result in a different deployment address.​    
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Car {
    address public owner;
    string public model;
    address public carAddr;
    uint public price;

    constructor(address _owner, string memory _model) payable {
        owner = _owner;
        model = _model;
        carAddr = address(this);
    }

    function setPrice(uint256 _price, address _owner) public {
        require(owner == _owner, "Invalid Owner");
        price = _price;
    }

    function buyCar(address _owner) external payable returns (string memory){
        require(msg.value >= price, "Invalid Price");
        (bool success, ) = owner.call{value: msg.value}("");
        if(success){
            owner = _owner;
            return "success";
        }
        return "fail";
    } 
}

contract CarFactory {
    Car[] public cars;
    Car car1 = new Car(msg.sender, "BMW"); // ----> we can also declare here

    constructor(string memory _model) payable {
        car1 = new Car(msg.sender, _model); // ---> deployment way same
    }

    function create(address _owner, string memory _model) public {
        Car car = new Car(_owner, _model); // ---> deployment way same
        cars.push(car);
    }

    function createAndSendEther(address _owner, string memory _model)
        public
        payable
    {
        Car car = (new Car) {value: msg.value}(_owner, _model); // ---> deployment way same
        cars.push(car);
    }

    function create2(address _owner, string memory _model, bytes32 _salt)
        public
    {
        Car car = new Car {salt: _salt}(_owner, _model); //// ---> deployment way same
        cars.push(car);
    }

    function create2AndSendEther(
        address _owner,
        string memory _model,
        bytes32 _salt
    ) public payable {
        Car car = (new Car){value: msg.value, salt: _salt}(_owner, _model); // // ---> deployment way same
        cars.push(car);
    }

    function setPrice(uint256 price) public {
        car1.setPrice(price, msg.sender);
    }

    function setPrice1(uint256 price, uint256 index) public {
        cars[index].setPrice(price, msg.sender);
    }

    function setPrice2(uint256 price, uint256 index) public {
        Car car = cars[index];
        car.setPrice(price, msg.sender);
    }

    function buyCar() external payable {
        car1.buyCar{value: msg.value}(msg.sender);
    }

    function buyCar1(uint256 index) external payable {
        cars[index].buyCar{value: msg.value}(msg.sender);
    }

     function buyCar2(uint256 index) external payable returns (string memory){
        Car car = cars[index];
        return car.buyCar{value: msg.value}(msg.sender);
    }

    function getCar(uint256 _index)
        public
        view
        returns (
            address owner,
            string memory model,
            address carAddr,
            uint256 price,
            uint256 balance
        )
    {
        Car car = cars[_index];

        return (car.owner(), car.model(), cars[_index].carAddr(), car.price(), address(car).balance);
    }

    function getCar1()
        public
        view
        returns (
            address owner,
            string memory model,
            address carAddr,
            uint256 price,
            uint256 balance
        )
    {
        Car car = car1;
        return (car.owner(), car1.model(), car1.carAddr(), car.price(), address(car).balance);
    }
}
