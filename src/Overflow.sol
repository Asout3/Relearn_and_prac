// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*
Overflow Bug — Write it, Exploit it, Fix it
This one is three parts like the reentrancy exercise.
Part 1 — Write the vulnerable contract
Write a contract called VulnerableToken that:

Has a balances mapping
Has a mint(address, uint256) function that adds to balance
Has a transfer(uint256) function that subtracts from sender and adds to receiver
Is written in a way where overflow/underflow is possible — meaning wrap it in unchecked to simulate pre-0.8 behavior

Part 2 — Write the exploit
Show how an attacker with 0 balance can call transfer and end up with a massive balance because of underflow. Write it as a comment or a separate Attacker contract showing the exact call.
Part 3 — Fix it
Write SafeToken — same contract but:

Uses Solidity 0.8 built-in overflow protection
Shows where you'd use unchecked intentionally for gas savings when you know it's safe



*/

// alright i tired my best but also some ai explained it to me so now i get it i will explain it to yall okay

// this is the vulnerable token contract
contract VulnerableToken {
    // this is the mapping to the address to the balance
    mapping(address => uint256) public balance;

    // this is the mint function i know i could have done like check for zero address and some things like that but i don't want that okay i just want to like for test example so it doesn't really matter
    function mint(address _address, uint256 amount) public {
        // minting here
        balance[_address] += amount;
    }

    // this is the transfer function i don't know i could use like .call or someshit like that but i didn't really feel like that not nesasery right now
    function transfer(address to, uint256 amount) public {
        // this is where things get real this is the unchecked part where solidity ignores the overflow and underflow so it doesn't check it here it just does what it is asked
        unchecked {
            balance[msg.sender] -= amount;
            balance[to] += amount;
        }
    }
}

// this is the attacker contract
contract attacker {
    // declar
    VulnerableToken token;

    constructor(address _address) {
        token = VulnerableToken(_address);
    }

    // this is where the real maths come here cuz let me explin how this works
    // so we call the transfer function with some random address with amount 1 since the attacher balance have 0 amount it does 0 - 1 so since it is uncheck solidyt and uint256 can't hold negative number it just does type(uint256).max  so the attacher address have type(uint256).max - 1
    // that is how he does it
    function attack() public {
        token.transfer(address(0x123), 1);
    }
}

// this is the safe contract i am not going trhough each line but i will do like tell you since solidity upgraded ^=0.8 so it checkes automatically so like it reverts and ya this one is safe
contract safeToken {
    mapping(address => uint256) public balance;

    function mint(address _address, uint256 amount) public {
        balance[_address] += amount;
    }

    function transfer(address to, uint256 amount) public {
        require(balance[msg.sender] >= amount, "Insufficient balance");
        balance[msg.sender] -= amount;
        balance[to] += amount;
    }
}

// i was also asked to explain why the unchecked{} thing existed in verion ^=0.8 so the reason is to save gas okay
// to save gas in  a way there are some parts where overflow or underflow will not occus so at that time using unchecked is way better for saing gas for exampele for loops they are good explmples and they are usefull
