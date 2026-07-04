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



*/