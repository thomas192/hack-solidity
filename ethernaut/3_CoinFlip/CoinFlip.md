# 3. Coin Flip

Goal :

- guess the correct outcome of the coin flip 10 times in a row

Methodology :

The randomness uses block hashes which is not random at all. We can use the same logic the contract uses to generate a "random" boolean and submit it in the same block to win every time.