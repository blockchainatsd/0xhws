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

Here, we have specified to use minimum version at least 0.7.0 and maximum
version 0.9.0. Solidity is a new language and is subject to continuous
improvement on an on-going basis and hence why you need to be careful when
specifying which compiler version you want. Many times, newer compiler versions
will break your code or make it behave differently. Also, make sure all your
contracts share the same version.

A contract in the sense of Solidity is a collection of code (its functions) and
data (its state) that resides at a specific address on the Ethereum blockchain.
The line uint256 number; declares a state variable called number of type uint256
(unsigned integer of 256 bits). You can think of it as a single slot in a
database that you can query and alter by calling functions of the code that
manages the database. In this example, the contract defines the functions store()
and get that can be used to modify  the value of the variable.

To access a member (like a state variable) of the current contract, you just
access it by defining the retrieve() function and directly returning number.

This contract does not do much yet apart from (due to the infrastructure built by Ethereum) allowing anyone to store a single number that is accessible by anyone in the world without a (feasible) way to prevent you from publishing this number. Anyone could call set again with a different value and overwrite your number, but the number is still stored in the history of the blockchain. Later, you will see how you can impose access restrictions so that only you can alter the number.
