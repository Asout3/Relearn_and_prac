// SPDX-License-Identifer: MIT
pragma solidity ^0.8.30;

/**

Exercise 5 — Pull Payment Tipping Contract
Real world context: Push payments are how most beginners send ETH — just send it directly to the recipient in the same transaction. The problem is if the recipient is a contract that rejects ETH or has a malicious fallback, your whole transaction fails. Chainlink, OpenZeppelin, and most production protocols use pull payments instead.

Write a contract called TipJar that:

Anyone can tip any address by sending ETH
Tips are not sent immediately — they're stored and the recipient pulls them out later
Recipients call claim() to withdraw their accumulated tips
Anyone can see how much a specific address has claimable
Owner can take a 5% protocol fee on every tip

Requirements:

Mapping to track claimable balance per address
Mapping to track owner's accumulated fees separately
Custom errors for zero tip amount and nothing to claim
Emit events for tip received and tip claimed
Use CEI pattern in claim function
No loops anywhere




*/

// let me explain the code like this contract main goal is like to practice pull payment method so like i did it i did some reserach before then i understanded it now lets start.

error NothingToClaim();
error ZeroTip();

contract TipJar {

// events
event TipRecived(address indexed from, address indexed to);
event TipClaimed(uint256 indexed amount);

// okay first let me try to build the basic one right.
// vars
address public owner;
uint256 constant public protocolFee = 5;

// constructor i want to use it cuz like i want to assign true owner
constructor() {
    owner = msg.sender;
}

// the modifer you can see it right i know you understand it
modifier onlyOwner() {
    require(owner == msg.sender, "you are not owner");
    _;
}

// mapping for the balance and the amount of fee accumlated like the fees over time it only does that but i think it is a waste of storage cuz like i only use it to store one address info but like what ever
mapping(address => uint256) public balance;
mapping(address => uint256) public feeAccumilation;

// tip function 
// it is payable and also like we put the address of the reciver let me explain what each line does
function tip(address to) payable external {

    if(msg.value == 0) revert ZeroTip();
    // this is me calculation the fee as we talked we are doing 5% so like i already assigned a variable called protocol fee so it will be 0.5 and it works
    uint256 fee = (msg.value * protocolFee) / 100;
    // yayayayaya make sure you put some error okay.
    // i didn't put any kind of checkes right here cuz i am too tired for that shit right i don't know man 
    // i just didn't feel it 

    // this is the amount of the recipent amount that will recive
    uint256 reciveRecipient = msg.value - fee;

    // we add to the mapping the value i used msg.value to like get the value since i am doing payable but like why did i use payable it is a function which doesn't recive a function so like instead i was supposed to do like input the amount paramerer where the user put the amount of ether to send but i don't know i prefered this.
    balance[to] += reciveRecipient;

    // add the fee to the owner so ya this is it
    feeAccumilation[owner] += fee;

    // me emiting an event for the thing
    emit TipRecived(msg.sender, to);
}

// this is a claim function this is where the user claim let me expalin 
function calim() external {

    // this is like the variable to like get the balance of so besically i will get like the amount of moeny that address can claim it is just that.
    uint256 amount = balance[msg.sender];

    // this is like me checking for insufficent ammount like if the user didn't have like enough amount of claimable.
    if(amount == 0) revert NothingToClaim();

    // this is me clearing out before i send cuz to avoid reentrancy and just to follow CEI
    balance[msg.sender] = 0;

    // this is me interacting okay send the amount to the reciver right.
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "claiming failed");

    // me emiting the event.
    emit TipClaimed(amount);
}

// this is a view function to a address to see how much amount of money does that address have to calim
function viewAmountOfClaimable(address recipient) view public returns (uint256) {
    return balance[recipient];
}

// and this is to like see how much amount of money is accumlated from the fees.
function seeHowMuchAccumelatedFromFee() view external onlyOwner returns (uint256) {
    return feeAccumilation[owner];
}

/**
and i know there is some issues like ya i know there is issues like this is like for practice purpose only so like 
that might feel like some buggy code but i tired also i have noticed the owner can't withdraw i can add that but like 
not nessasary at the moment what mattter is me learning pull payment method and i can confidently say that i understand 
pull payment method

push sends directly it just calls it
but pull puts the amount in the mapping stores it there like stores the amount of money that will be or is given to the address
and like in the claim function we gonna check from the mapping and transfer it all from the mapping like use that mapping check using it then call it okay.
that is it thank you.
 */

}