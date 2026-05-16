// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

error notEnoughMoney();

/**
 *     The Bank Contract
 * Write a Solidity contract called Bank that does the following:
 *
 * Anyone can deposit ETH into the contract
 * Users can withdraw their own ETH (only what they deposited)
 * Users can check their own balance
 * Owner can check the total ETH held by the contract
 *
 * Requirements:
 *
 * Track each user's balance separately
 * Emit an event on deposit and on withdrawal
 * No one can withdraw more than they deposited
 * Use a custom error instead of a require string for the insufficient balance case
 */

/*
okay me try to answer this question okay i will give this code to the ai so he can see my thinking process okay.
lets try to see the thing we are building a bank
so the thing that might get harder is like so like it askes us to like to track things separtely so like if we can find a way to like create a thing to create or track each user that will be it how do i solve that.
and that is obvious so we can do like an array which will have an address and the amount money they that so we can do that.
so ya i kinda figured it out we don't use array we use mapping i watched vidoe and shit so i think we good let me try to write up the code.
*/

// so let me explain this code let me start trying to write this teach me like i have totaly forget about this shit and i haven't learended and hard to find solidty course like not smart contract development only the solidty part the language but i tired to get things together.

// and i know it is not gas optimised but this is like my first solidty in like a lot of month.
contract Bank {
    // this are my events that i declared
    // NOTE: Event naming is not correct so we got to use PascalCase; eg. Deposit, Withdraw, FallBackWasCalled.
    // so in events we don't use indexed like when we serach is we use the indexed okay.
    event Deposit(address indexed _user, uint256 amount);
    event Withdraw(address indexed _user, uint256 amount);
    event FallBackWasCalled(address _user, uint256 amount);

    // as i said i can't use array cuz it have this special thing called mapping which is cool like it puts like shit1 : shit2 so it can do that
    address public owner;
    mapping(address => uint256) public balance;

    fallback() external payable {
        emit FallBackWasCalled(msg.sender, msg.value);
    }

    receive() external payable {
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not owner");
        _;
    }

    // my depostie function it accepts amount and add it to the msg sender so it is safe
    // so i was wrong the correction is like i forget about payable
    function deposite() public payable {
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // so this is witdraw function as you can see i tried to check if it does not have enough money then ya do my maths.
    // i got to supply the CEI check
    function withdraw(uint256 _amount) public {
        if (_amount > balance[msg.sender]) revert notEnoughMoney(); // check

        balance[msg.sender] -= _amount; // effect
        // this .call function it is kinda good but it is not very good for existing function so like ya it is kinda low level shit i will explaint it later.
        (bool success,) = msg.sender.call{value: _amount}(""); // intraction
        require(success, "Transfer failed");
        emit Withdraw(msg.sender, _amount);
    }

    // this is get function the amount of money that user have.
    function getBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function getTotalBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    // this is what i think and saw as fit
}
