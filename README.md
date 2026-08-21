<div align="center">

# Solidity from Scratch
### 20 exercises · 4 tiers · Solidity relearning

![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.30-363636?logo=solidity)
![Foundry](https://img.shields.io/badge/Foundry-forge-black)
![No OZ](https://img.shields.io/badge/OpenZeppelin-not%20used-orange)
![Status](https://img.shields.io/badge/phase-contracts%20done%20·%20tests%20next-blue)
![License](https://img.shields.io/badge/license-MIT-blue)

**Contracts-only repo — no full test suite yet.**

</div>

---

> **Notice — please read this first**
>
> This is **exercise / learning code**, not production Solidity. Phase 1 was about solving the questions and understanding the mechanics. I did **not** stop to make the files look like a polished library.
>
> I understand that smart contract development and testing are inherently linked. However, I intentionally separated them into distinct phases because I want to commit fully to the testing layer. By giving testing its own dedicated focus, I can deep-dive into the verification process, build stronger invariants, and develop a much more solid understanding of the security layer.
>
> If you open `src/`, you will see that on purpose:
>
> - **The exercise question is often pasted at the top of the file.** I start from the spec, then reason, then write. The question is left in so you can see what I was actually answering.
> - **Comments are messy and informal.** They are a thinking journal — slang, long notes, mid-solve questions — not production documentation.
> - **Naming is inconsistent.** Mix of styles (`deposite` vs `deposit`, `safeBank` vs `SafeBank`, event/error casing that does not match convention).
> - **Spelling and typos are in the code.** Function names, errors, comments (`Insufficent`, `VunlerableBank`, `ZeroAmountInputed`, etc.). I know they are there.
> - **Code quality is student-exercise quality.** Some files are uneven. A few safety/style issues are left as-is because the goal was “did I understand this system,” not “would I ship this.”
> - **Almost no real test coverage yet.** One early gas-report test. That is a known gap, not a hidden one.
>
> I am not asking you to ignore this. I am telling you I already see it.
>
> **Phase 2 is where this gets better and this kinds of things never happens** — naming, spelling, comments, structure, tests, scripts, and other. the production-style checks I skipped here so I could focus on solving the problems. That work will live in another repo. See [Phase 2 — what's next](#phase-2--whats-next).

---

I came back to Solidity after a few months away and chose the hard path on purpose.

Instead of grabbing OpenZeppelin and shipping something that *looks* finished, I rebuilt the core mechanics myself — from a written spec, with reasoning before code. Tokens, security patterns, vault math, staking rewards, AMM accounting, flash loans, governance, UUPS upgradeability, Merkle proofs, EIP-712 signatures, gas optimization, and a simplified DAO reentrancy case study.

This repo is **phase one**: implementation and protocol reasoning.  
**Phase two** is the engineering layer I still owe myself — real Foundry testing, scripting, and harder verification. That is not a vague “someday.” It is the plan. See [Phase 2 — what's next](#phase-2--whats-next).

> **Read this as learning code with serious intent — not production code, and not a finished portfolio product.**  
> No real funds. No “audited protocol” claims. Just me building, breaking things in my head, and writing it down.

---

## Why this exists

I wanted something I could point to and stand behind:

1. I can take a **spec** and turn it into working Solidity
2. I can reason about **state, invariants, and failure modes** before I type
3. I can implement **DeFi-style accounting** without copying a library
4. I can explain **trade-offs** in plain language
5. I stay **honest** about AI help, known limits, and what still needs work

If you only open a few files, start here:

| Priority | File | Why |
|---|---|---|
| 1 | [`src/Vault.sol`](src/Vault.sol) | Share math + inflation-attack thinking |
| 2 | [`src/StakingRewards.sol`](src/StakingRewards.sol) | Synthetix-style rewards without user loops |
| 3 | [`src/AMM.sol`](src/AMM.sol) | Constant product + LP accounting |
| 4 | [`src/UUPS_Exercise.sol`](src/UUPS_Exercise.sol) | Proxy / `delegatecall` / upgrade path |
| 5 | [`src/The_DAO_Hack.sol`](src/The_DAO_Hack.sol) | Reentrancy case study + historical context |
| — | [`src/adv.txt`](src/adv.txt) | The questions I try to ask on every contract |

---

## Phase 1 — the roadmap (done)

Twenty exercises across four tiers. Each tier builds on the last.

### Tier 1 — Foundations
Language basics and the building blocks of a contract.

| Contract | What I practiced |
|---|---|
| **Bank** | Deposits, withdrawals, mappings, custom errors, events, CEI |
| **Voting System** | Enums, structs, mappings, double-vote prevention |
| **Whitelist** | Dynamic arrays, swap-and-pop removal |
| **On-chain Todo** | Struct mappings, sequential IDs |
| **ERC20 from scratch** | Balances, allowances, transfers, approvals, supply |

### Tier 2 — Patterns & security
From syntax into how contracts actually get broken.

| Contract | What I practiced |
|---|---|
| **Reentrancy** | Vulnerable vs mitigated withdrawal flows |
| **NFT (ERC721-style)** | Ownership and transfer mechanics |
| **Treasury** | Role-based access control |
| **Overflow / Underflow** | Integer behavior before and after Solidity 0.8 |
| **TipJar** | Pull payments and safer withdrawal patterns |

### Tier 3 — DeFi mechanics
Hardest tier. Multiple concepts in one system.

| Contract | What I practiced |
|---|---|
| **Vault** | Share-price math, proportional ownership, ERC4626 inflation-attack study |
| **StakingRewards** | Synthetix-style `rewardPerTokenStored` — rewards without looping over users |
| **AMM** | Constant product (`x * y = k`), LP shares, my own `sqrt()` / `min()` |
| **Flash Loan** | ERC-3156-style lender/borrower callback flow |
| **Governor** | Token-weighted voting, quorum, timelock, on-chain execution |

### Tier 4 — Gas, cryptography & architecture
Closer to the EVM and protocol design.

| Contract | What I practiced |
|---|---|
| **Gas Optimization** | Storage packing, SLOAD caching, calldata, custom errors, safe `unchecked` — without changing behavior |
| **UUPS Upgradeability** | `delegatecall`, proxy storage, init, layout compatibility, V1 → V2 |
| **Merkle Airdrop** | Sorted-pair Merkle proof verification |
| **EIP-712 Signed Whitelist** | Domain separation, signature parsing, `ecrecover` |
| **The DAO Hack** | Vulnerable contract + attacker + fix, plus a write-up of the 2016 incident |

---

## Phase 2 — what's next

Phase 1 proved I can **build the mechanics**.  
Phase 2 is a separate track: **Verification & Systems Engineering** — testing, scripting, deeper gas/EVM, and designing systems from a one-paragraph prompt instead of a given spec.

That work lives in **another repo**. This one stays the contracts-only record.

The short thesis: AI can already write a passable ERC20, a staking contract, and a first-pass test file. Trying to out-type that is a losing game. Phase 2 is about the parts that still require a person — prove it works, prove it can be broken, catch what a generated test suite missed, ship it, and defend a design decision in writing.

The path (in the Phase 2 repo):

| | Focus |
|---|---|
| **Module 0** | Naming, NatSpec, layout, production norms — the standard Phase 1 did not hold itself to |
| **Tier A** | Foundry unit tests — happy path, errors, events, multi-actor flows |
| **Tier B** | Security tests — prove the exploit, then prove the fix |
| **Tier C** | Fuzz + invariants — Vault inflation, staking rewards, AMM `k`, Governor state |
| **Tier D** | Real deploy scripts — Anvil, Sepolia, verify, multi-contract wiring |
| **Tier E** | Gas from custom errors through storage layout and Yul |
| **Tier F** | Design from scratch — lending, escrow, threat model, then a Uniswap V4 hooks one-pager |

**Bottom line:** this repo is implementation. Phase 2 is verification, shipping, and judgment.

---

## How I work through an exercise

I do not start by typing Solidity.

**Spec → reason → design → implement → debug → security pass → explain.**

Before code, I try to answer:

- What state has to exist?
- What invariants must hold?
- What external calls happen?
- What edge cases break the happy path?

`src/adv.txt` is my short checklist for security, gas, logic, and design.

Comments in the source are more detailed (and more informal) than production docs on purpose. This repo is also a record of how my understanding grew — not only the final functions.

---

## Themes that keep showing up

**Security as design, not a final checklist.**  
CEI, reentrancy, access control, input validation, EIP-712 domain separation, storage layout for upgrades, careful external token calls.

**Accounting over “just functions.”**  
Vault shares, staking checkpoints, AMM reserves and LP shares — systems where the math *is* the protocol.

**EVM reality.**  
`delegatecall`, proxy vs implementation storage, calldata and signatures, `ecrecover`, packing, cost of storage reads.

---

## Scope

These are simplified learning implementations inspired by real designs. They are **not**:

- production protocols
- standards-complete libraries
- audited code
- something to deploy with real money

Some limitations are left on purpose so the lesson stays visible. The vault, for example, documents the inflation-attack problem instead of papering over it with a fix I had not fully reasoned through myself.

**Read this as evidence of learning, implementation skill, and security awareness.**

---

## AI use

I used AI as a learning tool, not as a substitute for understanding.

On tougher spots — reward accounting, EIP-712, proxy storage, gas optimization — AI helped me get unstuck or pressure-test my thinking. From there I worked the behavior myself, rewrote where I needed to, and left the reasoning in comments.

I would rather be clear about how I learned than pretend every line came out of thin air. What matters is whether I understand the code, its failure modes, and the trade-offs.

---

## Biggest takeaway

**Solidity syntax is the easy part.**

The hard part is state, invariants, external calls, trust boundaries, accounting, and execution context. Once those are clear, writing the contract is much less painful.

This repo is less “20 finished products” and more: I moved from language basics toward thinking in systems — and the next systems skill I am building is testing and verification.

---

## Repo layout

```text
src/       # 20 exercise contracts + adv.txt checklist
test/      # Foundry tests (gas-report only for now)
script/    # Foundry scripts (basic deploy exists; expanding in Phase 2)
lib/       # forge-std
```

```bash
forge build
forge test
forge fmt
```

---

<div align="center">

### Author

**Miki** [![](https://img.shields.io/badge/X-@Asout3-000000?logo=x&logoColor=white)](https://x.com/Asout3)  

CS student · building toward smart contract / protocol engineering

Phase 1: contracts from scratch · Phase 2: tests, scripts, gas optimization, and designing systems from scratch
[View Phase 2 Repository](https://github.com/Asout3/Relearn_and_prac_P2)

</div>
