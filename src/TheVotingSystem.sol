// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * THE QUESTION:
 *
 * The Voting Contract
 * Write a Solidity contract called Voting that does the following:
 *
 * Owner creates a proposal with a name and description
 * The contract has 3 states: Pending, Active, Closed — using an enum
 * Owner can start the vote (Pending → Active) and end it (Active → Closed)
 * Any address can vote — but only once, and only when state is Active
 * Anyone can view the current vote count
 *
 * Requirements:
 *
 * Use a struct for the proposal
 * Use an enum for the state
 * Track who has already voted using a mapping
 * Revert with a custom error if someone tries to vote twice
 * Revert with a custom error if voting isn't active
 * Emit an event when someone votes
 */

/*
HOW DO WE TACKEL THIS PROBLEM?

so the thing is i got some information so the proposal is like hardcoded and like it is on the construct so ya it is clear and easy now lets start.
let me write the code

i think i have figured it out

*/

// this is the custom errors
error AlreadyVoted();
error NotActive();

contract Voting {
    // this is the events
    event VotedYes(address indexed user);
    event VotedNo(address indexed user);
    event VoteActivated();
    event VotedCancled();

    // this is the struct proposal i don't know why it want me to use the struct it would be gas effective and like better if i use just a constructor
    struct Proposal {
        string name;
        string description;
    }

    // enum for the states of the voting.
    enum Status {
        Pending,
        Active,
        Closed
    }

    //the proposal struct assignment
    Proposal public proposal;
    // declar of the owner of the contract
    address private owner;

    // this is the constructor it have the name and the discription of the contract.
    constructor() {
        proposal.name = "Should we add pool in the house?"; // the name
        proposal.description = "should we add a swiming pool to the new house that we are building."; // the discription
        owner = msg.sender; // intialitation of the owner in the contract so no one could change it so its it won't fuck up
    }

    // for the onlyowner to check
    modifier onlyOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }

    Status public status; // declaring
    uint256 public yesVote; // storage for the yes vote
    uint256 public noVote; // storage for no vote

    mapping(address => bool) public hasVoted; // mapping for the has voted like to know who voted like if voted or not using bool

    // activate the voting
    function activeateTheVote() public onlyOwner {
        require(status == Status.Pending, "its not in in pending stage");

        status = Status.Active;
        emit VoteActivated();
    }

    // close the voting
    function closeTheVote() public onlyOwner {
        require(status == Status.Active, "it is not in active status");

        status = Status.Closed;
        emit VotedCancled();
    }

    // yes voting
    function voteYes() public {
        if (status != Status.Active) revert NotActive();
        if (hasVoted[msg.sender] == true) revert AlreadyVoted();

        yesVote++;
        hasVoted[msg.sender] = true;
        emit VotedYes(msg.sender);
    }

    // no voting
    function voteNo() public {
        if (status != Status.Active) revert NotActive();
        if (hasVoted[msg.sender] == true) revert AlreadyVoted();

        noVote++;
        hasVoted[msg.sender] = true;
        emit VotedNo(msg.sender);
    }

    // see the amount of yes votes
    function seeYesVote() public view returns (uint256) {
        return yesVote;
    }

    // see the amount of no votes
    function seeNoVote() public view returns (uint256) {
        return noVote;
    }

    // see the winner
    function seeWinner() public view returns (string memory) {
        require(status == Status.Closed, "the vote is not closed yet");

        if (yesVote > noVote) {
            return "yes won";
        } else if (yesVote == noVote) {
            return "its a tie";
        } else {
            return "no won";
        }
    }
}
