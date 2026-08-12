# Solidity from Scratch — A Structured Relearning Roadmap

This repository is a record of a focused, self-directed effort to rebuild and deepen my Solidity fundamentals from the ground up — no OpenZeppelin, no copy-pasted boilerplate, every primitive written and reasoned through by hand.

I'm a CS student working toward becoming a smart contract / protocol engineer. After a few months away from Solidity, I built this roadmap to get back to fluency and push past it — not just relearning syntax, but rebuilding the core mental models behind DeFi mechanics, security patterns, and gas-conscious design. Twenty exercises, four tiers, increasing in difficulty, each one built, debugged, and explained in my own words before moving to the next.

## Why this exists

Most "I learned Solidity" portfolios are a handful of tutorial follow-alongs. This isn't that. Every contract here was written from a spec, not copied from a course — I planned the architecture first, wrote the logic, broke it, fixed it, and documented the reasoning along the way. The goal wasn't to finish exercises. It was to understand *why* each pattern exists, so I recognize it instantly in new code, not just reproduce it when told to.

## Structure

**Tier 1 — Foundations**
Core syntax and patterns: a Bank contract (deposit/withdraw, CEI, custom errors), a Voting contract (enums, structs, double-vote prevention), a Whitelist (swap-and-pop array removal), an on-chain Todo List (struct mappings, sequential IDs), and an ERC20 built entirely from scratch.

**Tier 2 — Core Patterns & Security**
Where the real security thinking starts: a reentrancy exploit written and then patched (the Attacker/VulnerableBank/SafeBank set), an ERC721 from scratch, a multi-role Treasury with role-based access control, an integer overflow/underflow demonstration (pre- and post-Solidity 0.8), and a pull-payment TipJar.

**Tier 3 — DeFi Mechanics**
The hardest tier by a wide margin. An ERC4626-style single-asset vault (share-price math, and yes — I documented the inflation attack vulnerability myself rather than just implementing the fix blindly). A Synthetix-pattern staking contract with checkpoint-based reward distribution (the `rewardPerTokenStored` pattern that avoids ever looping over stakers). A constant-product AMM (`x*y=k`) with LP share math and my own `sqrt()`/`min()` implementations. A flash loan lender/borrower pair following the ERC-3156 callback standard. And a mini governance system — proposal lifecycle, quorum, timelocked execution — modeled on Compound's Governor Bravo pattern.

**Tier 4 — Gas & Advanced**
A gas optimization pass on a deliberately inefficient contract (storage packing, SLOAD caching, custom errors — with an explicit rule I held myself to: optimization must never change behavior). A UUPS upgradeable ERC20 with a working Proxy, `delegatecall`, and two independently deployed implementation contracts sharing one storage layout. A Merkle airdrop with sorted-pair proof verification. An EIP-712 signed whitelist with manual signature splitting and `ecrecover`. And a full reproduction of The DAO hack — the vulnerable contract, the exploit, the fix, and a researched write-up of what actually happened in June 2016 and why it changed smart contract security forever.

## Honest disclaimer

These are educational, unaudited contracts, not production code. I built them to learn — some naming is inconsistent, a handful of typos slipped through (`deposite`, `taksCount`, and a few others I've since learned to catch faster), and not every contract is fully gas-optimized or hardened for edge cases. That's intentional at this stage. I'd rather ship honest, working, understood code than polished code I couldn't explain. I'm still learning, and this repo will keep growing as I do.

Where I used AI assistance — mainly to unblock genuinely hard concepts (checkpoint-based reward math, EIP-712 domain separation, delegatecall storage mechanics) — I made sure I could explain the result back correctly before moving on. A few contracts leaned on that help more than others, and I'd rather say so than pretend otherwise.

## What's next

This roadmap was phase one. Phase two is Foundry — proper testing, fuzzing, invariant testing, deployment scripts — followed by a Uniswap V4 hooks project built around a real, defensible design decision, not a toy demo. That work is in progress.

## Author

**Miki** — [@Asout3](https://github.com/Asout3)
CS student, building toward smart contract / protocol engineering.