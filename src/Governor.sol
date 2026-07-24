// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30

/*

   ____                                      
  / ___| _____   _____ _ __ _ __   ___  _ __ 
 | |  _ / _ \ \ / / _ \ '__| '_ \ / _ \| '__|
 | |_| | (_) \ V /  __/ |  | | | | (_) | |   
  \____|\___/ \_/ \___|_|  |_| |_|\___/|_|                                                


*/

/*
   THIS ARE THE QUETSION AND THE EXPLANATION OF WHAT I NEED TO DO AND I WILL BE ACTING BASED ON IT OKAY.



Tier 3 Exercise 5 — Mini Governance System

Real world context: This is the Compound Governor Bravo pattern — cloned by Uniswap, Aave, and most major DAOs. When you see "proposal passed, executing in 2 days" on a DAO, this is the mechanism underneath it.

Write a contract called Governor that:

Uses an ERC20 token for voting power — 1 token = 1 vote
Anyone holding tokens can create a proposal — target address, calldata to execute, description
Anyone holding tokens can vote for or against a proposal — voting power based on their token balance
A proposal needs a quorum (minimum total votes) and more for-votes than against to pass
Voting lasts a fixed period — e.g. 3 days
If a proposal passes, there's a timelock delay — e.g. 2 days — before it can be executed
Anyone can execute a passed proposal after the timelock, which calls the target contract with the calldata

Requirements:

Enum for proposal state: Pending, Active, Succeeded, Defeated, Queued, Executed
Struct for proposal — id, proposer, target, calldata, votesFor, votesAgainst, start/end time, executed flag
Mapping to track who has voted on which proposal — one address can't vote twice on the same proposal
Custom errors for double voting, voting when not active, executing before timelock, executing a failed proposal

New concept here — calling arbitrary contract code from a passed proposal:

solidity
function execute(uint256 proposalId) external {
    Proposal storage p = proposals[proposalId];
    // checks: passed, timelock elapsed, not already executed
    (bool success, ) = p.target.call(p.callData);
    require(success, "Execution failed");
}

This is how a DAO actually changes something on-chain — a passed vote literally executes a function call on another contract, with no human clicking a button. That's the entire mechanism.



The big picture in one sentence:

People holding a token vote on proposals. If enough people vote yes, after a waiting period, anyone can trigger the proposal to actually execute on-chain — meaning it calls a real function on a real contract, automatically.

Step by step of how this actually gets used:

Alice holds 1000 governance tokens. She wants to change a parameter on some other contract — say, change the fee on your Treasury contract from Tier 2.
She calls propose() — she gives the target contract address (Treasury), the exact function call encoded as bytes (calldata), and a text description like "lower withdrawal fee to 3%".
For the next 3 days, anyone holding the governance token can call vote() — choosing for or against. Their vote weight equals how many tokens they hold.
After 3 days, voting ends. The contract checks: did enough total votes happen (quorum)? Did "for" beat "against"? If yes — the proposal succeeded.
There's now a mandatory 2 day wait — the timelock. This exists in real DAOs so people have time to notice a malicious proposal passed and react (exit funds, etc) before it actually executes.
After the timelock, anyone can call execute(). This makes your Governor contract literally call the Treasury contract with the exact calldata Alice specified back in step 2. The fee changes. No human clicked a "confirm" button on Treasury — the DAO vote did it directly.

The proposal lifecycle — this is the enum:

Pending   → proposal created, voting hasn't started yet (optional, can skip for simplicity)
Active    → voting window is open right now
Succeeded → voting ended, quorum met, votes for > votes against
Defeated  → voting ended, failed quorum OR against >= for
Queued    → succeeded and now waiting through timelock
Executed  → timelock passed, execute() was called, done

You can simplify — skip Pending and go straight to Active on creation if you want. Just be consistent.

Function by function — what each one does:

propose(address target, bytes calldata callData, string calldata description)

Anyone with tokens can call this
Creates a new Proposal struct, assigns it an auto-incrementing ID
Sets startTime = block.timestamp, endTime = block.timestamp + 3 days
Emits an event

vote(uint256 proposalId, bool support)

Checks: is this proposal currently in its voting window? Has this address already voted on this proposal?
Gets the caller's token balance — that's their vote weight
Adds that weight to either votesFor or votesAgainst
Marks hasVoted[proposalId][msg.sender] = true

state(uint256 proposalId) — a view function that calculates current state

If block.timestamp < endTime → still Active
If voting ended and votesFor + votesAgainst < quorum → Defeated
If voting ended and votesFor <= votesAgainst → Defeated
If voting ended and passed but not yet executed and timelock hasn't passed → Succeeded (or Queued if you track a separate queue timestamp)
If executed → Executed

execute(uint256 proposalId)

Checks the proposal actually succeeded and enough time has passed since it succeeded (the timelock)
Checks it hasn't already been executed
Calls target.call(callData)
Marks executed = true

The struct you need:

solidity
struct Proposal {
    uint256 id;
    address proposer;
    address target;
    bytes callData;
    string description;
    uint256 votesFor;
    uint256 votesAgainst;
    uint256 startTime;
    uint256 endTime;
    bool executed;
}

What "quorum" means concretely:

Just pick a number, like "10% of total token supply must vote" or a flat number like "1000 tokens worth of votes minimum." Store it as a state variable, check against votesFor + votesAgainst when determining if a proposal succeeded.
*/


/*

alright lets continue this is where i reason right so like i will do my shit here so as i always do no coding before have clear thing in my mind i need to reason it correctly and answer all question that comes to my mind.
i will start with reading the question and explanation carefully.

*/


contract Governor {

}