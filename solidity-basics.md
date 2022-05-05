# Learning Solidity

"Solidity is an object-oriented, high-level language for implementing smart
contracts. Smart contracts are programs which govern the behaviour of accounts
within the Ethereum state."
-[official Solidity doc](https://docs.soliditylang.org/en/latest/)

- [Installing solidity compiler](https://docs.soliditylang.org/en/latest/installing-solidity.html)

## Getting started

Let's look at this basic storage contract in Solidity hat sets the value of a variable and exposes it for other contracts to access. It is fine if you do not understand everything right now, we will go into more details later.

```javascript
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Storage {

    /*
        uint stands for unsigned integer, meaning non negative integers
        different sizes are available
            uint8   ranges from 0 to 2 ** 8 - 1
            uint16  ranges from 0 to 2 ** 16 - 1
            ...
            uint256 ranges from 0 to 2 ** 256 - 1
    */
    uint256 number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value 
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256){
        return number;
    }
}
```

Pragma is generally the first line of code within any Solidity file. pragma is a
directive that specifies the compiler version to be used for current Solidity
file.

Here, we have specified to use minimum version at least `0.7.0` and maximum
version `0.9.0`. Solidity is a new language and is subject to continuous
improvement on an on-going basis and hence why you need to be careful when
specifying which compiler version you want. Many times, newer compiler versions
will break your code or make it behave differently. Also, make sure all your
contracts share the same version.

A contract in the sense of Solidity is a collection of code (its functions) and
data (its state) that resides at a specific address on the Ethereum blockchain.
The line `uint256 number`; declares a state variable called `number` of type `uint256`
(unsigned integer of 256 bits). You can think of it as a single slot in a
database that you can query and alter by calling functions of the code that
manages the database. In this example, the contract defines the functions `store()`
and get that can be used to modify  the value of the variable.

To access a member (like a state variable) of the current contract, you just
access it by defining the `retrieve()` function and directly returning number.

This contract does not do much yet apart from (due to the infrastructure built
by Ethereum) allowing anyone to store a single number that is accessible by
anyone in the world without a (feasible) way to prevent you from publishing this
number. Anyone could call set again with a different value and overwrite your
number, but the number is still stored in the history of the blockchain. Later,
you will see how you can impose access restrictions so that only you can alter
the number.

## Currency example

The following contract implements the simplest form of a cryptocurrency. The
contract allows only its creator to create new coins (different issuance schemes
are possible). Anyone can send coins to each other without a need for
registering with a username and password, all you need is an Ethereum keypair.

```javascript
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

contract Coin {
    // The keyword "public" makes variables
    // accessible from other contracts
    // Immutable variables are like constants. Values of immutable 
    // variables can be set inside the constructor but cannot be
    // modified afterwards.
    address public immutable MINTER;
    mapping (address => uint) public balances;

    // Events allow clients to react to specific
    // contract changes you declare
    event Sent(address from, address to, uint amount);

    // Constructor code is only run when the contract
    // is created
    constructor() {
        MINTER = msg.sender;
    }

    // Sends an amount of newly created coins to an address
    // Can only be called by the contract creator
    function mint(address receiver, uint amount) public {
        require(msg.sender == MINTER);
        balances[receiver] += amount;
    }

    // Errors allow you to provide information about
    // why an operation failed. They are returned
    // to the caller of the function.
    error InsufficientBalance(uint requested, uint available);

    // Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        if (amount > balances[msg.sender])
            revert InsufficientBalance({
                requested: amount,
                available: balances[msg.sender]
            });

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}

```

The line `address public minter;` declares a state variable of type address. The address type is a 160-bit value that does not allow any arithmetic operations. It is suitable for storing addresses of contracts, or a hash of the public half of a keypair belonging to external accounts.

The keyword public automatically generates a function that allows you to access the current value of the state variable from outside of the contract. Without this keyword, other contracts have no way to access the variable. The code of the function generated by the compiler is equivalent to the following (ignore external and view for now):

```javascript
function minter() external view returns (address) { return minter; }
```

The next line, `mapping (address => uint) public balances;` also creates a public state variable, but it is a more complex datatype. The mapping type maps addresses to unsigned integers.

Mappings can be seen as hash tables which are virtually initialised such that every possible key exists from the start and is mapped to a value whose byte-representation is all zeros. However, it is neither possible to obtain a list of all keys of a mapping, nor a list of all values. Record what you added to the mapping, or use it in a context where this is not needed. Or even better, keep a list, or use a more suitable data type.

The getter function created by the public keyword is more complex in the case of
a mapping. You can use this function to query the balance of a single account.
It looks like the following:

```javascript
function balances(address account) external view returns (uint) {
    return balances[account];
}
```

The line `event Sent(address from, address to, uint amount);` declares an “event”,
which is emitted in the last line of the function send. Ethereum clients such as
web applications can listen for these events emitted on the blockchain without
much cost. As soon as it is emitted, the listener receives the arguments from,
to and amount, which makes it possible to track transactions.

The ***constructor*** is a special function that is executed during the creation of
the contract and cannot be called afterwards. In this case, it permanently
stores the address of the person creating the contract. The `msg` variable
(together with `tx` and `block`) is a special global variable that contains
properties which allow access to the blockchain. `msg.sender` is always the
address where the current (external) function call came from.

The functions that make up the contract, and that users and contracts can call
are `mint` and `send`.

The `mint` function sends an amount of newly created coins to another address.
The require function call defines conditions that reverts all changes if not
met. In this example, `require(msg.sender == minter);` ensures that only the
creator of the contract can call mint. In general, the creator can mint as many
tokens as they like, but at some point, this will lead to a phenomenon called
“overflow”. Note that because of the default Checked arithmetic, the transaction
would revert if the expression `balances[receiver] += amount; ` overflows, i.e.,
when `balances[receiver] + amount` in arbitrary precision arithmetic is larger
than the maximum value of `uint` __*(2**256 - 1)*__. This is also true for the statement
`balances[receiver] += amount;` in the function send.

The `revert` statement unconditionally aborts and reverts all changes similar to the require function, but it also allows you to provide the name of an error and additional data which will be supplied to the caller (and eventually to the front-end application or block explorer) so that a failure can more easily be debugged or reacted upon.

The send function can be used by anyone (who already has some of these coins) to send coins to anyone else. If the sender does not have enough coins to send, the if condition evaluates to true. As a result, the revert will cause the operation to fail while providing the sender with error details using the InsufficientBalance error.

## The Ethereum Virtual Machine

### Overview

The Ethereum Virtual Machine or EVM is the runtime environment for smart
contracts in Ethereum. It is not only sandboxed but actually completely
isolated, which means that code running inside the EVM has no access to network,
filesystem or other processes. Smart contracts even have limited access to other
smart contracts.

### Accounts

There are two kinds of accounts in Ethereum which share the same address space:
External owned accounts (EOA) that are controlled by public-private key pairs (i.e.
humans) and contract accounts which are controlled by the code stored together
with the account.

The address of an external account is determined from the public key while the address of a contract is determined at the time the contract is created (it is derived from the creator address and the number of transactions sent from that address, the so-called “nonce”).

Regardless of whether or not the account stores code, the two types are treated equally by the EVM.

Every account has a persistent key-value store mapping 256-bit words to 256-bit words called storage.

Furthermore, every account has a balance in Ether (in “Wei” to be exact, 1 ether
is 10**18 wei) which can be modified by sending transactions that include Ether.
Transactions are paid with ether. Similar to how one dollar is equal to 100 cent, one ether is equal to 10^18 wei.

### Transaction

A transaction is a message that is sent from one account to another account
(which might be the same or empty, see below). It can include binary data (which
is called “payload”) and Ether. If the target account contains code, that code
is executed and the payload is provided as input data.

### Gas

Upon creation, each transaction is charged with a certain amount of gas that has
to be paid for by the originator of the transaction (`tx.origin`). While the EVM
executes the transaction, the gas is gradually depleted according to specific
rules. If the gas is used up at any point (i.e. it would be negative), an
out-of-gas exception is triggered, which ends execution and reverts all
modifications made to the state in the current call frame.


```javascript
 // Using up all of the gas that you send causes your transaction to fail.
    // State changes are undone.
    // Gas spent are not refunded.
    function forever() public {
        // Here we run a loop until all of the gas are spent
        // and the transaction fails
        while (true) {
            i += 1;
        }
    }
```

This mechanism incentivizes economical use of EVM execution time and also compensates EVM executors (i.e. miners / stakers) for their work. Since each block has a maximum amount of gas, it also limits the amount of work needed to validate a block.

The gas price is a value set by the originator of the transaction, who has to pay gas_price * gas up front to the EVM executor. If some gas is left after execution, it is refunded to the transaction originator. In case of an exception that reverts changes, already used up gas is not refunded.

Since EVM executors can choose to include a transaction or not, transaction
senders cannot abuse the system by setting a low gas price.

### Structs

You can define your own type by creating a struct.

They are useful for grouping together related data.

Structs can be declared outside of a contract and imported in another contract.

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Todos {
    struct Todo {
        string text;
        bool completed;
    }

    // An array of 'Todo' structs
    Todo[] public todos;

    function create(string memory _text) public {
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

    // Solidity automatically created a getter for 'todos' so
    // you don't actually need this function.
    function get(uint _index) public view returns (string memory text, bool completed) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    // update text
    function update(uint _index, string memory _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    // update completed
    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}
```

### Data Locations - Storage, Memory and Calldata

Variables are declared as either storage, memory or calldata to explicitly specify the location of the data.

storage - variable is a state variable (store on blockchain)

memory - variable is in memory and it exists while a function is being called

calldata - special data location that contains function arguments

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract DataLocations {
    uint[] public arr;
    mapping(uint => address) map;
    struct MyStruct {
        uint foo;
    }
    mapping(uint => MyStruct) myStructs;

    function f() public {
        // call _f with state variables
        _f(arr, map, myStructs[1]);

        // get a struct from a mapping
        MyStruct storage myStruct = myStructs[1];
        // create a struct in memory
        MyStruct memory myMemStruct = MyStruct(0);
    }

    function _f(
        uint[] storage _arr,
        mapping(uint => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something with storage variables
    }

    // You can return memory variables
    function g(uint[] memory _arr) public returns (uint[] memory) {
        // do something with memory array
    }

    function h(uint[] calldata _arr) external {
        // do something with calldata array
    }
}
```

### Assignment

- Finish the TODOs in Auction.sol

