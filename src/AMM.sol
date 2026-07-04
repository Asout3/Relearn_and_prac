// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;


   █████████   ██████   ██████ ██████   ██████
  ███░░░░░███ ░░██████ ██████ ░░██████ ██████ 
 ░███    ░███  ░███░█████░███  ░███░█████░███ 
 ░███████████  ░███░░███ ░███  ░███░░███ ░███ 
 ░███░░░░░███  ░███ ░░░  ░███  ░███ ░░░  ░███ 
 ░███    ░███  ░███      ░███  ░███      ░███ 
 █████   █████ █████     █████ █████     █████
░░░░░   ░░░░░ ░░░░░     ░░░░░ ░░░░░     ░░░░░ 
                                              
                                              
                                              
/**
    This is the exercise and the question that i asked:

Tier 3 Exercise 3 — x*y=k AMM
Real world context: This is Uniswap V2 core — the exact math your V4 study builds on top of.

Write a contract called AMM that:

Holds reserves of two ERC20 tokens — tokenA and tokenB
Anyone can add liquidity by depositing both tokens and receiving LP shares
Anyone can remove liquidity by burning LP shares and getting tokens back
Anyone can swap tokenA for tokenB or tokenB for tokenA
Anyone can view the reserves

The invariant — never changes during a swap:

x * y = k

// reserveA * reserveB = constant

Swap math:

// How much tokenB you get when swapping in amountA:
amountOut = (reserveB * amountIn) / (reserveA + amountIn)

LP share math — same pattern as your vault:
// First liquidity:
shares = sqrt(amountA * amountB)

// After that:
shares = min(
    (amountA * totalShares) / reserveA,
    (amountB * totalShares) / reserveB
)

Requirements:

Two token interfaces
addLiquidity(uint256 amountA, uint256 amountB) → mints LP shares
removeLiquidity(uint256 shares) → burns shares, returns tokens
swapAforB(uint256 amountIn) → swaps tokenA for tokenB
swapBforA(uint256 amountIn) → swaps tokenB for tokenA
Track reserveA and reserveB as state variables
Custom errors for zero amounts, insufficient liquidity, insufficient output


Solidity has no built-in square root — use this standard implementation for the first LP deposit:
solidityfunction sqrt(uint256 y) internal pure returns (uint256 z) {
    if (y > 3) {
        z = y;
        uint256 x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}
This one connects your vault share math, your ERC20 knowledge, and your Uniswap study into one contract. Go.

ME:
i have this question after you answer this i will be off building: so when the user put tokens does they have to put two tokens like are they forced to put both token A and B, or they can just put one of those.and you said X * Y = K  , i belive X is the amount of X token in the vault and Y is the amount Y token in the vault but what about K like why in my note book i wrote like x * y = L^2 can you explain that.in the swap maths formula you said reserveA and B do you mean like amount of token x and y is that what you are trying to say.in the LP share maths you gave me two formula like sqrt(amounta * amountb)
and also other saying after that and other thing saying shares = min()  so also can you explain that and also  i couldn't really understand what is the use of min() in solididty.Synthesized liquidity pool mechanics and LP share calculation nuancesSynthesized liquidity pool mechanics and LP share calculation nuancesGood questions. Let me go through each.

1. Do they have to deposit both tokens?
Yes, both, and in the correct ratio. This is important — if the pool already has 100 tokenA and 200 tokenB (ratio 1:2), you can't just deposit 50 tokenA and 10 tokenB randomly. You'd be changing the price unfairly. You either:
Deposit in the exact current ratio (best practice, what Uniswap enforces)
Or the contract calculates the correct matching amount and uses only what's needed, refunding the rest (more advanced, we won't do this for the exercise)
For this exercise, keep it simple: just accept whatever amountA and amountB the user gives you, and let the share math handle fairness. First depositor sets the ratio. Everyone after should ideally match it, but we won't enforce that here.

2. x * y = k and your notebook's x * y = L²
You are correct — k and L² are the same thing, just different notation depending on the source.
x * y = k
k is just "the constant." It's not a meaningful number by itself — it's just whatever x * y equals at any given moment, and it stays fixed during swaps.
Some material writes it as:
x * y = L²
Because L here represents "liquidity" as a single number, and L = sqrt(x * y). So squaring L gives you back k. This is actually exactly why the sqrt() function shows up in your LP share calculation — sqrt(amountA * amountB) is literally calculating L, the liquidity value, for the first deposit.
Same concept, two different textbooks calling it different letters.

3. reserveA / reserveB — are these the token balances?
Yes exactly. reserveA = how much tokenA is currently sitting in the AMM contract. reserveB = how much tokenB. These update every time someone adds liquidity, removes liquidity, or swaps.
They represent x and y in the formula. So:
reserveA * reserveB = k

4. The two share formulas, and what min() does
First deposit ever:

shares = sqrt(amountA * amountB)

Nobody has a ratio to match yet, so you just calculate liquidity directly from the two amounts.
Every deposit after that:

shares = min(
    (amountA * totalShares) / reserveA,
    (amountB * totalShares) / reserveB
)
Here's why min() matters. Say someone deposits slightly out of ratio — maybe they meant to match the pool's ratio but got it slightly wrong, or they're trying to game the system. If you calculated shares using only amountA, they'd get one number. Using only amountB, they'd get a different number. Taking the min() of both protects the pool — it gives the depositor the smaller of the two calculations, so they can never get more shares than their weakest-matching token justifies. It's a safety mechanism against manipulation.
min() in Solidity — there's no built in one. You write it yourself:

function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
}

That's it. Just a comparison. Add that helper function alongside your sqrt() function.

Go build it. Come back when you have a draft.

*/

/**
    SO I WILL BE BUILDING THIS:

so as i have learned that in the process of building first i have to fully understand what i am going to build and try to plan it as much as possible so i will be doing that.
how i am going to understand so i will ask and answer it my self and design and ask question and solve the issues as i go through, as i learned the main thing is not the code writing it is the engineering so ya lets be it.

so lets start!

i am asked to build an AMM and given proper instructions so the exercise is like not really like exactly the same uniswap AMM but mostly similar which will teach me important things so i will  continue:

here is the exercise: 
```
Tier 3 Exercise 3 — x*y=k AMM
Real world context: This is Uniswap V2 core — the exact math your V4 study builds on top of.

Write a contract called AMM that:

Holds reserves of two ERC20 tokens — tokenA and tokenB
Anyone can add liquidity by depositing both tokens and receiving LP shares
Anyone can remove liquidity by burning LP shares and getting tokens back
Anyone can swap tokenA for tokenB or tokenB for tokenA
Anyone can view the reserves

The invariant — never changes during a swap:

x * y = k
// reserveA * reserveB = constant

Swap math:
// How much tokenB you get when swapping in amountA:
amountOut = (reserveB * amountIn) / (reserveA + amountIn)

LP share math — same pattern as your vault:
// First liquidity:
shares = sqrt(amountA * amountB)

// After that:
shares = min(
    (amountA * totalShares) / reserveA,
    (amountB * totalShares) / reserveB
)


Requirements:

Two token interfaces
addLiquidity(uint256 amountA, uint256 amountB) → mints LP shares
removeLiquidity(uint256 shares) → burns shares, returns tokens
swapAforB(uint256 amountIn) → swaps tokenA for tokenB
swapBforA(uint256 amountIn) → swaps tokenB for tokenA
Track reserveA and reserveB as state variables
Custom errors for zero amounts, insufficient liquidity, insufficient output


Solidity has no built-in square root — use this standard implementation for the first LP deposit:

function sqrt(uint256 y) internal pure returns (uint256 z) {
    if (y > 3) {
        z = y;
        uint256 x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}
This one connects your vault share math, your ERC20 knowledge, and your Uniswap study into one contract. Go.
```
i know you can see it above but i bring it here for clarity and to make it easier for me okay.

okay lets start i want to start with the requirements and i will write like how do i achive those requirement and at the end i will try to show the full picture then after full understanding i will start wrtiting the code.

1. Two token interfaces :- so i think this is the easiest one i will just put two interface those will be token X and token Y.

2. addLiquidity(uint256 amountA, uint256 amountB) → mints LP shares :- so i think this is the one where the user will add liquidity and in thier putting liqudity they will recive LP token.
    so how i am going to do that as i have reserached there must be like proportion when the user put the liquidity they input must be proportion either they will recive an error or the code will handle it then give the rest of the money like make it proportional and return the unwanted liqudity to the provider.
    but i am not required to do that since this is just an exercise i will accept the money.

    so as from the not this is how i handle the share minting: 
    for the first liquidity provider  i will use this: 
                shares = sqrt(amountA * amountB)

    now since the pool have some tokens in it i will be using this:
                shares = min(
                                (amountA * totalShares) / reserveA,
                                (amountB * totalShares) / reserveB
                            )
    then i will be minting LP token based on the share result, this means i need to also need another erc20 token which will be importing the erc20 token that i wrote and use everywhere in this exercieses.
    when i they want to burn they will burn the lp token and like get the original value they puted in the value i will use this formula to calculate the original value: shares / totalShare.
    so in real life like uniswap and shit they use like pools for the lp like they have an lp pool and like based on the fee the amount of fee will be acumlated in the pool and your lp will also grow then you will profit more money so like i will not be doing it since this is not like full project so ya.
 
 3. removeLiquidity(uint256 shares) → burns shares, returns tokens :- this is what i said before so no probelm i gave the formula like 
                                                
                                                ownership = shares / totalshare    this will get me the percentage which i will not probably use.

                                this is the real formula: amountA = (shares × reserveA) / totalShares  and amountB = (shares × reserveB) / totalShares

                                so to do the maths i will probably do like calculate both and send them to them .
     
     so shares will be like the lp token they have recvied then it gets burned the shares and like the get the original value, ya so the rest will be like on code so i am sure that i will face some problems like when i am writing but that is a process i can't know all the problem while i am writing like trying to plan if i have any problem i will take a step back and try to analyze an solve it.
 
 4. swapAforB(uint256 amountIn) → swaps tokenA for tokenB :- so as it mentioned it have its own formula so this is the formula:

                                            amountOut = (reserveB * amountIn) / (reserveA + amountIn)

     to clear up it means you give up tokenA to get tokenB so ya.
     so as you can this like this is the swap for changing A for B and at this time the reserve of tokenA will increase so i have to deals with also like i don't know is there things that i have to deal with let me thing so i will probabaly came to it when i write the code
 5. swapBforA(uint256 amountIn) → swaps tokenB for tokenA :- this is the same as like before but different formula here is the formula:

                                            amountOut = (reserveA * amountIn) / (reserveB + amountIn)

     to clear up it means you give up tokenB to get tokenA so ya.
     so same shit also here.
 6. Track reserveA and reserveB as state variables :- so yep i will track them like state variables are like the main thing i get like troubled the nameing so like i will try my best like naming it and like listing them i will try my best.

 so that is me answering for the requirement so next i will try to like write up my questions if i have any.

 how do i handle the lp tokens:- i will just mint and send and burn while burning since i don't have to like calculate fee and like increase in the lp like i don't have to create a vault for it i just need to like so that is simple.
 
 okay then i don't have any thing in my mind currently i will probably face something in the like coding but it is okay it is part of the process.


*/