// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/*

   ____
  / ___| _____   _____ _ __ _ __   ___  _ __
 | |  _ / _ \ \ / / _ \ '__| '_ \ / _ \| '__|
 | |_| | (_) \ V /  __/ |  | | | | (_) | |
  \____|\___/ \_/ \___|_|  |_| |_|\___/|_|


*/

/*
   THIS IS NOT PRODUCTION CODE AND IT IS SO GAS INEFFICENT AND IT MIGHT HAVE BUGS OR WHAT EVER IT IS JUST
   EXERCISE OKAY FOR PRACTICE OKAY THAT IS IT AND I THINK I LEARNED SOME OUT OF IT. I JUST TIRED TO COMPLETE
   THE REQUIREMENTS AND SO YA I LOVED IT GOOD PROGRESS AND I AM GOING TO KEEP WORKING ON HARDER EXERCISE AND PROJECTS.

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


so as you can see it is kinda long insturction and shit right fuck this shit right so let me try to answer on the like things that i need to do and like also the requirements let me answer on them.

- Uses an ERC20 token for voting power — 1 token = 1 vote:
  i will add an erc20 interface and use it as a voting power this is easy.

- Anyone holding tokens can create a proposal — target address, calldata to execute, description:
  okay this one is also easy i will try to do like need token to propose and like in the function i will accept that right.

- Anyone holding tokens can vote for or against a proposal — voting power based on their token balance:
   so i think like the voter need to know on what topic they are voting so like i need to find a way to notify them or make them pick on what they are voting or like does it work like one proposal at a time like i can do like create a proposal id and the voter can put it also then vote on that id right what else there is.

- A proposal needs a quorum (minimum total votes) and more for-votes than against to pass:
   do i need to like create a general one for the all dao or like on every proposal but i think it should be a general that is hwo it supposed to be

- A proposal needs a quorum (minimum total votes) and more for-votes than against to pass:
   okay will do that no worreis

- If a proposal passes, there's a timelock delay — e.g. 2 days — before it can be executed:
   okay i will make sure i will do that in the function.

- Anyone can execute a passed proposal after the timelock, which calls the target contract with the calldata
  mmmm... wait let me resreach on that.



okay lets continue.

what do you think i should do i belive i got to do this one like i got this one no need for other right so yes no worries
so how am i gonig to write the contract as i said i am going to start with like planning i don't start with writing so i try to answer all question which i did at some point no worries like
in writing, developing or designing, or creating arctecture so you start with the plan and question and you try to answer the question that is you wrote or get and read docs or what ever you got and u can build from that i think it is also good way of seeing it answering all the question makes it easier cuz you know you will have full information about what you are going to build fully understand it then you write the contract as i said before writing the contract is like the second part write if you do the plan and answer all the important question the writing contract will be easier than ever.

okay i think i tried to answer the question and i have function and shit so like the explanation is really good so like let me start

*/

error AlreadyVoted();
error VotingNotActive();
error ProposalNotSuccessful();
error TimeLockNotPassed();

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract Governor {
    event ProposalCreated(address indexed target, bytes callData, string description);

    address public immutable token;

    constructor(address _address) {
        token = _address;
    }

    uint256 public currentID = 1;
    uint256 public constant VOTING_PERIOD = 259200;
    uint256 public constant TIMELOCK_DELAY = 172800;
    uint256 public constant QUORUM = 100e18;
    uint256 public constant MAX_DESCRIPTION_LENGTH = 512;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    enum ProposalState {
        Pending,
        Active,
        Succeeded,
        Defeated,
        Queued,
        Executed
    }

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

    function propose(address target, bytes calldata callData, string calldata description) public {
        // i need to follow the CEI i need to check this things since creating proposal take some gas i need to check if there is no slop proposal
        // i need to check for zero address and if they can affroed it which is the token they hold.
        require(IERC20(token).balanceOf(msg.sender) > 0, "You don't have enough power to propose");
        require(target != address(0), "zero address contract is not allowed");
        require(bytes(description).length <= MAX_DESCRIPTION_LENGTH, "too much wtf make it short");

        uint256 startingTime = block.timestamp;
        uint256 endingTime = block.timestamp + VOTING_PERIOD;

        proposals[currentID] = Proposal({
            id: currentID,
            proposer: msg.sender,
            target: target,
            callData: callData,
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            startTime: startingTime,
            endTime: endingTime,
            executed: false
        });
        currentID++;

        //i am going to emit an event
        // i need to also add some important datas right so okay i will be back at it.
        emit ProposalCreated(target, callData, description);
    }

    function state(uint256 proposalId) public view returns (ProposalState) {
        if (proposals[proposalId].executed) {
            return ProposalState.Executed;
        } else if (block.timestamp < proposals[proposalId].endTime) {
            return ProposalState.Active;
        } else if (proposals[proposalId].votesFor + proposals[proposalId].votesAgainst < QUORUM) {
            return ProposalState.Defeated;
        } else if (proposals[proposalId].votesFor > proposals[proposalId].votesAgainst) {
            if (block.timestamp < proposals[proposalId].endTime + TIMELOCK_DELAY) {
                return ProposalState.Queued;
            }

            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    function vote(uint256 proposalId, bool support) external {
        require(IERC20(token).balanceOf(msg.sender) > 0, "You don't have enough power to vote");
        if (hasVoted[proposalId][msg.sender]) revert AlreadyVoted();
        if (state(proposalId) != ProposalState.Active) revert VotingNotActive();

        uint256 weight = IERC20(token).balanceOf(msg.sender);

        if (support) {
            proposals[proposalId].votesFor += weight;
        } else {
            proposals[proposalId].votesAgainst += weight;
        }

        hasVoted[proposalId][msg.sender] = true;
    }

    function execute(uint256 proposalId) public {
        if (state(proposalId) != ProposalState.Succeeded) revert ProposalNotSuccessful();
        require(!proposals[proposalId].executed, "its already executed");
        // i comment this one out because it is the one who got to get out cuz you know like we don't have to use block.timestamp so i remove it i know i use a lot of time in this exercise but they were nessasary so like i got no option so like ya that is why.
        //if (block.timestamp < proposals[proposalId].endTime + TIMELOCK_DELAY) revert TimeLockNotPassed();

        Proposal storage p = proposals[proposalId];

        proposals[proposalId].executed = true;

        (bool success,) = p.target.call(p.callData);
        require(success, "failed executing");
    }
}
