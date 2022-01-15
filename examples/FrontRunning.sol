// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
Here is an example of a contract that is vulnerable to front running. FindThisHash sends  
10 eth to the user that finds the string that matches the target hash. Now let's suppose that 
user A found the solution. His transaction will be placed in a transaction pool before it 
is mined. Miners choose which transaction they mine first based the amount of gas paid. So 
even if A found the solution first, user B could read A's transaction, and send a similar 
transaction with a higher gas price that will be more likely to be mined first.
*/

contract FindThisHash {
    bytes32 public constant hash =
        0x564ccaf7594d66b1eaaea24fe01f0585bf52ee70852af4eac0cc4b04711cd0e2;

    constructor() payable {}

    function solve(string memory solution) public {
        require(
            hash == keccak256(abi.encodePacked(solution)),
            "Incorrect answer"
        );

        (bool sent, ) = msg.sender.call{value: 10 ether}("");
        require(sent, "Failed to send Ether");
    }
}
