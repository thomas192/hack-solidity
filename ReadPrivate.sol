// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

/*
Even though private variables are not readable by other contracts,
they can still be read. This is what we are going to do.

How the EVM stores state variables :
- SV are stored in a 2**256 slots long array.
- Each slot can store up to 32 bytes.
- SV are stored in the order they are declared in.
- Neighboring SV that can fit in 32 bytes are packed in the same slot.
*/

contract Vault {
    // slot 0
    uint256 public count = 123; // 32 bytes
    // slot 1
    address public owner = msg.sender; // 20 bytes
    bool public isTrue = true; // 1 byte
    uint16 public u16 = 31; // 2 bytes
    // slot 2
    bytes32 private password;
    // constants do not use storage
    uint256 public constant const = 123;
    // slot 3, 4, 5 (one for each array element)
    bytes32[3] public data;
    struct User {
        uint256 id;
        bytes32 password;
    }
    // dynamic array
    // slot 6 : length of the array
    // starting from slot keccak256(6) : array elements
    // slot keccak256(slot) + (index * elementSize) : array element
    // slot = 6 and elementSize = 2 (1 (uint) + 1 (bytes32))
    User[] private users;
    // mapping
    // slot 7 : empty
    // entries are stored at keccak256(key, slot)
    // key = map key, slot = 7
    mapping(uint256 => User) private idToUser;

    constructor(bytes32 _password) {
        password = _password;
    }

    function addUser(bytes32 _password) public {
        User memory user = User({id: users.length, password: _password});
        users.push(user);
        idToUser[user.id] = user;
    }
}

/*
After deploying the contract on Rinkeby and initializing some variables,
we can start reading all the SV of the contract (public or not) with a brownie 
console connected to Rinkeby.
Contract address : 0x39D7f097410a5E8714b04682D765802099A7dc2C

>>> addr = "0x39D7f097410a5E8714b04682D765802099A7dc2C"
>>> web3.eth.getStorageAt(addr, 0) // slot 0
HexBytes('0x000000000000000000000000000000000000000000000000000000000000007b')
>>> int("0x7b", 16)
123 // count
>>> web3.eth.getStorageAt(addr, 1)
HexBytes('0x000000000000000000001f017b43935e95b04cb3bad943382d110e81c1f904a2') // slot 1
>>> int("0x1f", 16)
31 // u16
>>> web3.eth.getStorageAt(addr, 2)
HexBytes('0x00000000000000000000000000000074686973697374686570617373776f7264') // slot 2
>>> web3.toText(0x00000000000000000000000000000074686973697374686570617373776f7264)
'thisisthepassword' // password
// access users array
web3.solidityKeccak(['uint256'], [6])
HexBytes('0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d3f')
>>> hash="0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d3f"
>>> web3.eth.getStorageAt(addr, hash) // id of first user
HexBytes('0x0000000000000000000000000000000000000000000000000000000000000000')
// to access the password of the first user we need to increase the hash by one
>>> hash="0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d40"
>>> web3.eth.getStorageAt(addr, hash)
HexBytes('0x000000000000000000000000000000000070617373776f72646f667573657231')
>>> web3.toText(0x000000000000000000000000000000000070617373776f72646f667573657231)
'passwordofuser1'
// repeat the process for the second user of the array
>>> hash="0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d41"
>>> web3.eth.getStorageAt(addr, hash)
HexBytes('0x0000000000000000000000000000000000000000000000000000000000000001')
>>> hash="0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d42"
>>> web3.eth.getStorageAt(addr, hash)
HexBytes('0x000000000000000000000000000000000070617373776f72646f667573657232')
>>> web3.toText(0x000000000000000000000000000000000070617373776f72646f667573657232)
'passwordofuser2'
// access idToUser mapping
>>> web3.solidityKeccak(['uint256'], [7])
HexBytes('0xa66cc928b5edb82af9bd49922954155ab7b0942694bea4ce44661d9a8736c688')
>>> web3.solidityKeccak(['uint256', 'uint256'], [1, 7]) // second user the array
HexBytes('0xb39221ace053465ec3453ce2b36430bd138b997ecea25c1043da0c366812b828')
>>> hash="0xb39221ace053465ec3453ce2b36430bd138b997ecea25c1043da0c366812b828"
>>> web3.eth.getStorageAt(addr, hash)
HexBytes('0x0000000000000000000000000000000000000000000000000000000000000001')
// increment by one to get the password
>>> hash=0xb39221ace053465ec3453ce2b36430bd138b997ecea25c1043da0c366812b829
>>> web3.eth.getStorageAt(addr, hash)
HexBytes('0x000000000000000000000000000000000070617373776f72646f667573657232')
>>> web3.toText(0x000000000000000000000000000000000070617373776f72646f667573657232)
'passwordofuser2'
*/
