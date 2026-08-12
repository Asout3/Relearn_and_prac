# My Solidity Structured Relearning Roadmap and Exercises 
 
> **Note:** This repository does not yet include a test suite. Every contract here was written and manually reasoned through in Remix & Foundry, not validated with Foundry tests, fuzzing, or CI. Building that out  unit tests, fuzz tests, invariant tests, deployment scripts — is the explicit next phase of this work, covered in the [Development environment](#development-environment) and [What's next](#whats-next) sections below.
 
This repository documents my return to Solidity after several months away from the language. Instead of jumping straight into frameworks and production abstractions, I deliberately rebuilt the underlying mechanics myself: state management, token standards, security patterns, DeFi accounting, cryptographic authorization, upgradeability, gas optimization, and historical exploits.
 
The goal isn't to present these contracts as production-ready protocols. The goal is to show that I can take a specification, reason about the system before writing any code, implement the core mechanics, identify how it can fail, and explain the trade-offs behind the design.
 
## What this repository demonstrates
 
- Solidity fundamentals and contract architecture
- ERC20- and ERC721-style token implementations, written without OpenZeppelin
- Checks-Effects-Interactions and reentrancy mitigation
- Custom errors, events, modifiers, mappings, structs, and access control
- Vault and share-accounting mechanics inspired by ERC4626
- Synthetix-style reward-per-token accounting without per-user loops
- Constant-product AMM math (`x * y = k`) and LP share accounting
- ERC-3156-style flash loan mechanics
- Governance with quorum, voting, timelocks, and on-chain execution
- Storage layout and `delegatecall` mechanics behind UUPS-style upgradeability
- Merkle proof verification
- EIP-712 typed-data hashing and `ecrecover`
- Gas optimization through storage packing, SLOAD caching, calldata, custom errors, and controlled unchecked arithmetic
- A simplified reproduction of the vulnerability pattern behind The DAO hack
## The learning path
 
Twenty exercises across four progressively harder tiers. Each tier builds on the concepts introduced in the one before it, rather than treating every contract as an isolated tutorial.
 
### Tier 1 — Foundations
The language and the basic building blocks of a smart contract.
 
- **Bank** — deposits, withdrawals, mappings, custom errors, events, and CEI
- **Voting System** — enums, structs, mappings, and preventing double voting
- **Whitelist** — dynamic arrays and swap-and-pop removal
- **On-chain Todo List** — struct mappings and sequential IDs
- **ERC20 from scratch** — balances, allowances, transfers, approvals, events, and supply accounting
### Tier 2 — Core Patterns & Security
Moving from syntax into security and reusable contract patterns.
 
- **Reentrancy** — vulnerable and mitigated withdrawal flows
- **ERC721-style NFT** — ownership and transfer mechanics
- **Treasury** — role-based access control and restricted operations
- **Overflow / Underflow** — integer arithmetic behavior before and after Solidity 0.8
- **TipJar** — pull-style payment mechanics and withdrawal patterns
### Tier 3 — DeFi Mechanics
Where the exercises start combining multiple concepts into protocol-level accounting systems. This was the hardest tier by a wide margin.
 
- **Vault** — share-price math, proportional ownership, deposits, withdrawals, and an explicit study of the ERC4626 inflation-attack problem
- **StakingRewards** — Synthetix-style `rewardPerTokenStored` accounting that distributes rewards without ever looping over stakers
- **AMM** — constant-product pricing, LP shares, reserve accounting, and my own `sqrt()` and `min()` implementations
- **Flash Loan** — lender/borrower flow based on the ERC-3156 callback model
- **Governor** — token-weighted voting, quorum, proposal state, timelocks, and arbitrary target execution
### Tier 4 — Gas, Cryptography & Advanced Architecture
Mechanisms that require a deeper understanding of the EVM and of protocol design.
 
- **Gas Optimization** — storage packing, cached storage reads, calldata, custom errors, and safe unchecked arithmetic — with one rule I held myself to throughout: optimization should never change what the contract actually does
- **UUPS-style Upgradeability** — proxy storage, `delegatecall`, initialization, storage layout compatibility, and upgrading from V1 to V2
- **Merkle Airdrop** — proof verification using sorted Merkle pairs
- **EIP-712 Signed Whitelist** — typed-data domain separation, manual signature parsing, and `ecrecover`
- **The DAO Hack Case Study** — a simplified vulnerable contract, an attacker contract, the fix, and a researched write-up of the 2016 reentrancy exploit and why it changed smart contract security for good
## How I approached the exercises
 
I treated this as an engineering exercise, not a set of copy-paste tutorials. For each problem, the process was roughly:
 
**Specification → reasoning → design → implementation → debugging → security review → explanation.**
 
Before writing any code, I tried to work out the state that needed to exist, the invariants the contract had to preserve, the external calls it would make, and the edge cases that could break the intended behavior. Getting that right first is what actually made the code easier to write.
 
The comments in the source files preserve a lot of that reasoning. They're more detailed and more informal than production documentation would be, because this repository is also a record of how my understanding developed while I was building each system — not just the finished output.
 
## Engineering themes
 
**Security**
Treated as part of the design process, not a checklist run at the end. Recurring patterns across the exercises: Checks-Effects-Interactions, reentrancy mitigation, access control, input validation, signature validation, replay protection through EIP-712 domain separation, storage-layout compatibility for upgradeable contracts, and failure handling around external token calls. The DAO exercise closes the roadmap by tying one of the most important vulnerability patterns in smart contract history to the actual incident that made it widely understood.
 
**DeFi accounting**
Several exercises are built around accounting, not just exposed functions. The vault and staking exercises forced me to reason about proportional ownership, checkpoints, and reward accumulation — and specifically why protocols avoid ever iterating over every user. The AMM combines those ideas with reserve invariants and LP share accounting.
 
**EVM mechanics**
The later exercises move closer to how the EVM actually executes contracts: `delegatecall` and execution context, proxy storage versus implementation logic, calldata layout and signature parsing, `ecrecover`, storage slots and packing, and the gas cost of storage access. The point was to understand what the higher-level abstractions are actually doing underneath.
 
## Development environment
 
These exercises were developed interactively and iteratively, working through each contract, reasoning about its design, then implementing and debugging it. The repository structure is intentionally simple right now, so the Solidity itself and the reasoning behind it stay easy to read.
 
The next phase of this roadmap moves the work into a proper Foundry workflow: unit tests, fuzz testing, invariant testing, deployment scripts, gas benchmarking, and CI. That work is in progress, not yet reflected in this repo.
 
## Scope and limitations
 
This is educational code, not production protocol code.
 
The implementations favor understanding the underlying mechanics over completeness, battle-tested abstractions, or production hardening. Several exercises deliberately simplify real protocols so one concept stays visible instead of being buried inside a mature framework — the AMM, the governance system, the upgradeable token, the vault, and the staking system are all learning implementations inspired by real designs, not claims of standards compliance or production equivalence.
 
Some exercises intentionally leave known limitations in place as part of the lesson. The vault, for example, documents the inflation-attack problem rather than hiding it behind a fix I hadn't actually reasoned through myself.
 
Read this repository as evidence of learning, implementation ability, security awareness, and protocol reasoning — not as a library anyone should deploy with real funds.
 
## Use of AI assistance
 
I used AI as a learning tool, not as a substitute for understanding the systems I was building.
 
On some exercises — particularly reward accounting, EIP-712, proxy storage, and gas optimization — AI helped me get unblocked, pressure-tested my reasoning, or gave me a starting point. From there I worked through the actual behavior, tested it, and rewrote or explained the relevant ideas in my own words before moving on.
 
I kept that process visible in the source comments instead of presenting the work as entirely unassisted. What actually matters to me is whether I understand what the code does and can reason about its security and trade-offs — and I'd rather be upfront about how I got there than pretend otherwise.
 
## What I learned
 
The biggest lesson from this roadmap: Solidity syntax is the easy part.
 
The hard part is reasoning about state, invariants, external calls, trust boundaries, accounting, and execution context. Writing the actual contract gets much easier once those questions are answered first — which is why the later exercises spend less time on syntax and more time on protocol mechanics and failure modes.
 
This repository is less a collection of finished projects and more a record of moving from basic Solidity constructs toward actually thinking in terms of smart contract systems.
 
## What's next
 
This roadmap is the foundation for the next phase of my work. That phase is deeper Foundry work — stronger unit test coverage, fuzz testing, invariant testing, deployment and scripting workflows, real gas benchmarking — and protocol-level projects built on top of it.
 
The longer-term direction is building and understanding more realistic DeFi infrastructure, including a Uniswap V4 hooks project with an explicit protocol-design rationale behind it, not another tutorial clone.
 
## Author
 
**Miki** — [@Asout3](https://github.com/Asout3)
Computer Science student focused on smart contract and protocol engineering.