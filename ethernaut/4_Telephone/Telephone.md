# 4. Telephone

Goal :

- claim ownership of the contract

Methodology :

tx.origin needs to be different from msg.sender to change the owner. This can be achieved be creating a contract that will call Telephone.changeOwner().