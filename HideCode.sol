// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
Here is an example of how malicious code can be hided. Let's say a user 
can see the code of Foo and Bar but not Mal. The user will think callBar()  
will call Bar.log(). However, if Foo is deployed with the address of Mal, 
Mal.log() will be called.

In this case one should make sure that the code of the external contract in 
Foo corresponds to Bar. We could do that if the address was declared as public.
*/

contract Foo {
    Bar bar;

    constructor(address _bar) {
        bar = Bar(_bar);
    }

    function callBar() public {
        bar.log();
    }
}

contract Bar {
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}

// this code is hidden in a separate file
contract Mal {
    event Log(string message);

    // we can execute the same exploit even if this function does not
    // exist by using the fallback
    function log() public {
        emit Log("Mal was called");
    }
}
