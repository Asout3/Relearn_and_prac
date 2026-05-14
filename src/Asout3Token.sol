// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

//  THIS IS FOR LEARNING PURPOSE ONLY MISTAKES AND BUGS COULD OCCURE.


/* The question

Exercise 5 — ERC20 From Scratch
Write a contract called MyToken that implements a basic ERC20 token without using OpenZeppelin. Build it yourself.

Token has a name, symbol, and 18 decimals
Owner gets the total supply on deploy
Anyone can transfer tokens to another address
Anyone can approve another address to spend on their behalf
Approved spenders can transferFrom — spend from someone else's balance
Anyone can check any address's balance
Anyone can check the allowance between two addresses

Requirements:

mapping(address => uint256) for balances
mapping(address => mapping(address => uint256)) for allowances — nested mapping
Custom errors for insufficient balance and insufficient allowance
Emit Transfer and Approval events
Total supply set in constructor, all goes to deployer

*/

/*
so i have heared like i got to like i got this like things i will try my best and cross check it okay 
lets do it.
*/

// alright let me try to explain how i did this it might have mistake but i will try to fix or imporve my mistakes;

// this are custom error for not being allowed and for not having enough balance;
error InsufficentAllowance();
error InsufficentBalance();

// the Asout3 token contract
contract Asout3Token {
    // two most important events
    event Transfer(address indexed sender, address indexed receiver, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // variables here
    // owner of this contract
    uint256 public totalSupply;
    // mapping to track balance of the user 
    mapping(address => uint256) public balanceOf;
    // mapping to track the allowance and the amount allowed
    mapping(address => mapping(address => uint256)) public allowance;
    // name of the token
    string public name;
    // symbold of toke
    string public symbol;
    // decimal of da token
    uint8 public decimals;

    // constructor this helps like to intialize i added total supply by my self to like put it on deploy 
    // so the owner gets it all i belive
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    function totalSupplies() public view returns (uint256) {
        return totalSupply;
    }
    
    // transfer function
    function transfer(address _to, uint256 _amount) external returns (bool) {
        if(balanceOf[msg.sender] < _amount) revert InsufficentBalance();

        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;  
    }

    // approve functoin
    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    // transfer from function
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        if(allowance[_from][msg.sender] < _amount) revert InsufficentAllowance();
        if(balanceOf[_from] < _amount) revert InsufficentBalance();

        allowance[_from][msg.sender] -= _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    // check approval function
    function checkApproval(address _owner, address _to) external view returns (bool) {
        if(allowance[_owner][_to] == 0) return false;

        return true;
    }
}