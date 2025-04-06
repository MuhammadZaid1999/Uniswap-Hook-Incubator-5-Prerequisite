/*
You can define your own type by creating a struct.
They are useful for grouping together related data.
Structs can be declared outside of a contract and imported in another contract.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./StructDeclaration.sol";

contract Todos {
    // An array of 'Todo' structs
    Todo[] public todos;

    function create(string calldata _text) public {
        // 3 ways to initialize a struct
        // - calling it like a function
        todos.push(Todo(_text, false));

        // key value mapping
        todos.push(Todo({text: _text, completed: false}));

        // initialize an empty struct and then update it
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialized to false

        todos.push(todo);
    }

    // Solidity automatically creates a getter for 'todos' so
    // you don't actually need this function.
    function get(uint256 _index)
        public
        view
        returns (string memory text, bool completed)
    {
        Todo memory todo = todos[_index];
        return (todo.text, todo.completed);
    }

    // Solidity automatically creates a getter for 'todos' so
    // you don't actually need this function.
    function get1(uint256 _index)
        public
        view
        returns (Todo memory) 
    {
        Todo memory todo = todos[_index];
        return todo;
    }

    // update text
    function updateText(uint256 _index, string calldata _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    function updateText1(uint256 _index, string calldata _text) public {
        todos[_index].text = _text;
    }

    // update completed
    function toggleCompleted(uint256 _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }

    function toggleCompleted1(uint256 _index) public {
        todos[_index].completed = !todos[_index].completed;
    }
}


contract Todos1 {
    Todo public todos1;

    function create(string calldata _text) public {
        // 4 ways to initialize a struct
        // - calling it like a function
        todos1 = Todo(_text, false);

        // key value mapping
        todos1 = Todo({text: _text, completed: false});

        // initialize an empty struct and then update it
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialized to false
        todos1 = todo;

        // initialize an empty struct and then update it
        Todo storage todo1 = todos1;
        todo1.text = _text;
        // todo.completed initialized to false
    }

    // Solidity automatically creates a getter for 'todos' so
    // you don't actually need this function.
    function get1()
        public
        view
        returns (Todo memory)
    {
        return todos1;
    }

     function get()
        public
        view
        returns (string memory text, bool completed)
    {
        Todo memory todo = todos1;
        return (todo.text, todo.completed);
    }

    function updateText1(string calldata _text) public {
        Todo storage todo = todos1;
        todo.text = _text;
    }

    function updateText2(string calldata _text) public {
        todos1.text = _text;
    }

    function toggleCompleted1() public {
        Todo storage todo = todos1;
        todo.completed = !todo.completed;
    }

    function toggleCompleted2() public {
        todos1.completed = !todos1.completed;
    }
}
