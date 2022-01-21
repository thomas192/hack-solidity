# 7. Force

Goal :

- make the balance of the contract greater than 0 even though it's not supposed to be be able to receive eth

Methodology :

We can force sending eth to this contract by using selfdestruct().