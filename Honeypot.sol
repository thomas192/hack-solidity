// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
This is a demonstration of how we can trap a hacker. The contract Bank seems vulnerable 
to a reentrancy attack. However Bank.logger will be deployed using Honeypot's address and 
not Logger's address. Therefore Bank is not vulnerable to a reentrancy attack because the 
malicious transaction will eventually revert.

Note that no one can actually withdraw eth in this example.
*/

contract Bank {
    mapping(address => uint256) public balances;

    Logger logger;

    constructor(Logger _logger) {
        logger = Logger(_logger);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "deposit");
    }

    function withdraw(uint256 _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient funds");
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Failed to send eth");
        balances[msg.sender] -= _amount; // looks vulnerable to reentrancy attack
        logger.log(msg.sender, _amount, "Withdraw");
    }
}

contract Logger {
    event Log(address caller, uint256 amount, string action);

    function log(
        address _caller,
        uint256 _amount,
        string memory _action
    ) public {
        emit Log(_caller, _amount, _action);
    }
}

// this code is hidden in a separate file
// see HideCode.sol for an in-depth understanding
contract Honeypot {
    // the actual function that will be called in withdraw()
    function log(
        address _caller,
        uint256 _amount,
        string memory _action
    ) public {
        if (equal(_action, "Withdraw")) {
            revert("It's a trap");
        }
    }

    // since there is no easy way to compare strings in solidity we can use hashes
    function equal(string memory _a, string memory _b)
        public
        pure
        returns (bool)
    {
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}

// the hacker's contract who will try to perform a reentrancy attack
// see Reentrancy.sol for an in-depth understanding
contract AttackingContract {
    Bank bank;

    constructor(Bank _bank) {
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }
}
