// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*

  _____.__                .__      
_/ ____\  | _____    _____|  |__   
\   __\|  | \__  \  /  ___/  |  \  
 |  |  |  |__/ __ \_\___ \|   Y  \ 
 |__|  |____(____  /____  >___|  / 
                 \/     \/     \/  
       .__                         
       |  |   _________    ____    
       |  |  /  _ \__  \  /    \   
       |  |_(  <_> ) __ \|   |  \  
       |____/\____(____  /___|  /  
                       \/     \/                          
                             
*/


/*

lets start with today question so i have recived todays exercise it kidna seems like it need some reserach but i like that like discovering doing new things is alwasy good and i love that so let  me paste the question and i will try to break it down okay.

Tier 3 Exercise 4 — Flash Loan Contract
Real world context: This is the Aave flash loan pattern. Borrow any amount with zero collateral, as long as you pay it back — plus a fee — in the same transaction. If you don't, the whole transaction reverts as if it never happened. This is one of the most important DeFi primitives to understand, and it shows up constantly in audit contests.

Write two contracts:
1. FlashLender — holds a pool of ERC20 tokens and lends them out

Anyone can call flashLoan(uint256 amount)
It sends amount tokens to the caller
It calls a callback function on the caller — onFlashLoan(uint256 amount, uint256 fee)
After the callback returns, it checks the lender's balance is back to at least what it was before, plus the fee
If not repaid with the fee, the whole transaction must revert
Fee is a flat 0.3% of the loan amount

2. FlashBorrower — a simple example borrower

Implements onFlashLoan(uint256 amount, uint256 fee)
Inside this function, it does whatever it wants with the borrowed tokens (for this exercise, nothing meaningful — just approve the lender to pull back amount + fee)
Must have enough of its own tokens to cover the fee, since it's borrowing "for free" but still owes the fee


Requirements:

FlashLender checks balance before and after the loan — this is the core security mechanism
Use require or custom error if the loan isn't repaid with fee
The borrower must call approve on the lender before or during its callback so the lender can pull the repayment
Emit an event when a flash loan is issued and repaid.

wait let me reserach about it. 
*/

/**
 * I will try to explain my understanding of it.
 * 
 * This flashloan thing is an ERC3156. so it is fully documented we have strutured way of working with it.
 * We have two contract lender and borrower. so we gonna work with them. My Goal for this session is compelete the exercise so i will be working toward it so i might jump or miss some important things that will be implemented in real protocols.
 * 
 * I will explain more as i code and try to tackle the exercise. 
 *
 */

 /**
  * LETS TRY TO BREAK IT DOWN.
  * 
  * We have two contracts `FlashLender` and `FlashBorrower`.
  * 
  * Lets start. 
  * 
  * FlashLender:- 
  * 
  * I can be called by anyone, it send `amount` to the caller it calls a callback function onFlashLoan from the borrower contract.
  * After the callback ended it checks the lender balance to know if it retuns it all plus the fee. 
  * The fee is 0.03%.
  * 
  * so this is it as i see this it is not exactly the same as the main erc3156 so it reduce some things but i will try to implement as best as i could.
  * 
  * Now lets pass to the FlashBorrower.
  * 
  * FlashBorrower:-
  * 
  * It is besically the onFlashLoan function. It does what it want inside.
  * It must have enough token to cover its fees.
  * 
  * REQUIREMENTS:
  * 
  * FlashLender checks balance before and after the loan — this is the core security mechanism.
  * Use require or custom error if the loan isn't repaid with fee.
  * The borrower must call approve on the lender before or during its callback so the lender can pull the repayment.
  * Emit an event when a flash loan is issued and repaid.
  * 
  * 
  * SINCE THIS IS EXERCISE CODE THE COMMENT AND SOME IMPLEMENTATION MAY NOT BE AS BEST AS IT COULD HAVE BEEN.
  * 
  * okay lets start.
  */

// I will start with placing an interface for IERC20 token.
// honestly i didn't write this interface code i been over this shit every time i do some exercise doing an interface i can import OZ contract but i can't do that so i got this interface from google ai. i know i could have also put my ERC20 contract here but this is okay.
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



contract FlashLender {
  // from the origianl erc3156 there is a function called maxFlashLoan but i am not going to implement it.

  /**
   * @dev this flashFee function is customized by my self the original flashFee function have like token address and it checks if that token address is allowed but for this exercise i only do calculate the amount and i don't check the token address i dont even ask for toekn address.
   * @dev i did 1000 because we are asked 0.3% so since solidity doesn't have decimal if i devide it by 1000 it could get the wanted 0.3%.
   */ 
  function flahsFee(uint256 _amount) external view returns (uint256) {
    return (_amount * 3) / 1000; 
  }

}