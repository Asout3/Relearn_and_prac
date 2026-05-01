import { useState } from "react";

const tiers = [
  {
    id: 1,
    label: "TIER 1",
    title: "Syntax & Foundations",
    color: "#4ade80",
    bg: "#052e16",
    est: "~1 week",
    goal: "Get your hands back on the wheel. Syntax muscle memory, types, storage — no shortcuts.",
    topics: [
      { id: "1.1", name: "Types & Variables", desc: "uint, int, bool, address, bytes, string — storage vs memory vs calldata" },
      { id: "1.2", name: "Functions & Visibility", desc: "public/private/internal/external, pure/view/payable, return values" },
      { id: "1.3", name: "Mappings & Arrays", desc: "mapping(address=>uint), dynamic arrays, nested mappings, iteration gotchas" },
      { id: "1.4", name: "Structs & Enums", desc: "Custom types, packing structs for gas, enum state machines" },
      { id: "1.5", name: "Events & Errors", desc: "emit, indexed params, custom errors vs require strings (gas diff)" },
      { id: "1.6", name: "Constructor & Fallback", desc: "constructor(), receive(), fallback() — when each fires" },
      { id: "1.7", name: "Inheritance & Interfaces", desc: "is, super, virtual/override, interface contracts, abstract contracts" },
      { id: "1.8", name: "Modifiers", desc: "Writing reusable guards, modifier order, reentrancy risk in modifiers" },
    ],
    exercises: [
      "Write a Bank contract: deposit, withdraw, check balance — no exploits allowed",
      "Build a Voting contract with enum states (Pending, Active, Closed)",
      "Create a Whitelist contract using mappings + events",
      "Write a simple Todo list stored fully on-chain",
      "Implement a basic ERC20 from scratch (no OpenZeppelin)",
    ],
    testnet: "Deploy your Bank contract on Sepolia. Verify on Etherscan.",
  },
  {
    id: 2,
    label: "TIER 2",
    title: "Core Patterns & Security",
    color: "#60a5fa",
    bg: "#0c1a2e",
    est: "~1.5 weeks",
    goal: "Where most devs are weak. Patterns that get you hired and bugs that get protocols drained.",
    topics: [
      { id: "2.1", name: "Ownable Pattern", desc: "Owner management, transferOwnership, renounceOwnership" },
      { id: "2.2", name: "Access Control", desc: "Role-based permissions, OpenZeppelin AccessControl, grantRole/revokeRole" },
      { id: "2.3", name: "Reentrancy", desc: "Classic attack, checks-effects-interactions, ReentrancyGuard" },
      { id: "2.4", name: "Overflow & SafeMath", desc: "Solidity 0.8 built-ins, unchecked blocks, when to use them" },
      { id: "2.5", name: "Pull vs Push Payments", desc: "Why push payments are dangerous, withdrawal pattern" },
      { id: "2.6", name: "ERC20 Deep Dive", desc: "approve/allowance race condition, permit (EIP-2612), transfer hooks" },
      { id: "2.7", name: "ERC721 from Scratch", desc: "tokenURI, ownerOf, transferFrom, safeTransferFrom, onERC721Received" },
      { id: "2.8", name: "Pausable & Emergency Stop", desc: "Circuit breaker pattern, when to use, centralization tradeoff" },
    ],
    exercises: [
      "Implement a reentrancy-vulnerable contract, then fix it",
      "Build ERC721 NFT contract from scratch with mint limits",
      "Create a multi-role access controlled Treasury contract",
      "Write a contract with intentional overflow bug — then patch it",
      "Build a tipping contract using pull payment pattern",
    ],
    testnet: "Deploy ERC721 on Sepolia. Mint 3 NFTs. View on OpenSea testnet.",
  },
  {
    id: 3,
    label: "TIER 3",
    title: "DeFi Mechanics",
    color: "#f472b6",
    bg: "#2d0a1e",
    est: "~2 weeks",
    goal: "This is where your Uniswap study pays off. You'll recognize what you're building.",
    topics: [
      { id: "3.1", name: "ETH & Token Vaults", desc: "ERC4626 standard, share-based accounting, deposit/withdraw/redeem" },
      { id: "3.2", name: "Staking & Rewards", desc: "Reward per token algorithm, stake/unstake/claim, compounding" },
      { id: "3.3", name: "Price Oracles", desc: "Chainlink integration, TWAP concept, oracle manipulation attack vectors" },
      { id: "3.4", name: "AMM Basics", desc: "x*y=k invariant, addLiquidity, swap math, slippage" },
      { id: "3.5", name: "Flash Loans", desc: "Callback pattern, atomicity requirement, legitimate use cases" },
      { id: "3.6", name: "Governance", desc: "Token-weighted voting, proposal/vote/execute lifecycle, timelock" },
      { id: "3.7", name: "Lending Basics", desc: "Collateral ratio, liquidation, interest rate models" },
      { id: "3.8", name: "Fee Mechanisms", desc: "Protocol fees, fee-on-transfer tokens, fee distribution" },
    ],
    exercises: [
      "Build a staking contract with reward distribution (don't use loops)",
      "Implement a simple x*y=k AMM with addLiquidity and swap",
      "Write a vault using ERC4626 standard",
      "Create a flash loan contract — borrower must return funds in same tx",
      "Build a mini governance system: propose, vote, execute",
    ],
    testnet: "Deploy your AMM. Add liquidity. Perform a swap. Check reserves before/after.",
  },
  {
    id: 4,
    label: "TIER 4",
    title: "Gas & Advanced Patterns",
    color: "#fb923c",
    bg: "#1c0a00",
    est: "~1.5 weeks",
    goal: "This separates intermediate from senior. Gas awareness, proxies, assembly — the real flex.",
    topics: [
      { id: "4.1", name: "Gas Optimization", desc: "Storage packing, memory vs storage, calldata, unchecked, batch ops" },
      { id: "4.2", name: "Yul / Inline Assembly", desc: "mload/mstore, sload/sstore, assembly blocks, when to use vs avoid" },
      { id: "4.3", name: "Proxy Patterns", desc: "Transparent proxy, UUPS, delegatecall mechanics, storage collision" },
      { id: "4.4", name: "Upgradeable Contracts", desc: "Initializer vs constructor, storage gaps, upgrade safety" },
      { id: "4.5", name: "Merkle Proofs", desc: "Merkle tree structure, proof verification, airdrop use case" },
      { id: "4.6", name: "Signatures & EIP-712", desc: "ECDSA, ecrecover, structured data signing, gasless transactions" },
      { id: "4.7", name: "Multi-call & Batch", desc: "Multicall3, batch patterns, atomicity guarantees" },
      { id: "4.8", name: "Security Mindset", desc: "Read exploits (Rekt.news), reproduce attacks, write invariants" },
    ],
    exercises: [
      "Optimize a gas-heavy contract — reduce deployment cost by 20%+",
      "Implement a UUPS upgradeable ERC20 — deploy v1, upgrade to v2",
      "Build a Merkle airdrop — users prove inclusion, claim tokens",
      "Write an EIP-712 signed message verifier (gasless whitelist)",
      "Reproduce a simple reentrancy hack from history in a test environment",
    ],
    testnet: "Deploy UUPS proxy. Upgrade it live on Sepolia. Verify both implementations.",
  },
];

const totalExercises = tiers.reduce((a, t) => a + t.exercises.length, 0);

export default function Roadmap() {
  const [open, setOpen] = useState(1);
  const [done, setDone] = useState({});

  const toggle = (key) => setDone(prev => ({ ...prev, [key]: !prev[key] }));
  const doneCount = Object.values(done).filter(Boolean).length;
  const pct = Math.round((doneCount / totalExercises) * 100);

  return (
    <div style={{
      minHeight: "100vh",
      background: "#0a0a0a",
      fontFamily: "'Courier New', monospace",
      color: "#e5e5e5",
      padding: "32px 20px",
    }}>
      {/* Header */}
      <div style={{ maxWidth: 720, margin: "0 auto" }}>
        <div style={{ marginBottom: 8, fontSize: 11, letterSpacing: 4, color: "#555", textTransform: "uppercase" }}>
          Solidity Relearn Protocol
        </div>
        <h1 style={{ margin: 0, fontSize: 28, fontWeight: 900, letterSpacing: -1, lineHeight: 1 }}>
          INTERMEDIATE <span style={{ color: "#4ade80" }}>ROADMAP</span>
        </h1>
        <p style={{ color: "#666", fontSize: 13, marginTop: 8 }}>
          4 tiers · {totalExercises} exercises · testnet deploys · ~6 weeks
        </p>

        {/* Progress Bar */}
        <div style={{ marginTop: 20, marginBottom: 32 }}>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 11, color: "#555", marginBottom: 6 }}>
            <span>PROGRESS</span>
            <span style={{ color: "#4ade80" }}>{doneCount}/{totalExercises} exercises · {pct}%</span>
          </div>
          <div style={{ height: 4, background: "#1a1a1a", borderRadius: 2 }}>
            <div style={{
              height: "100%",
              width: `${pct}%`,
              background: "linear-gradient(90deg, #4ade80, #60a5fa)",
              borderRadius: 2,
              transition: "width 0.4s ease"
            }} />
          </div>
        </div>

        {/* Tiers */}
        {tiers.map(tier => (
          <div key={tier.id} style={{ marginBottom: 16 }}>
            {/* Tier Header */}
            <button
              onClick={() => setOpen(open === tier.id ? null : tier.id)}
              style={{
                width: "100%",
                background: open === tier.id ? tier.bg : "#111",
                border: `1px solid ${open === tier.id ? tier.color + "44" : "#222"}`,
                borderRadius: 8,
                padding: "16px 20px",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                transition: "all 0.2s",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
                <span style={{
                  fontSize: 10,
                  fontWeight: 700,
                  letterSpacing: 2,
                  color: tier.color,
                  background: tier.color + "22",
                  padding: "3px 8px",
                  borderRadius: 3,
                }}>{tier.label}</span>
                <span style={{ fontWeight: 700, fontSize: 15, color: "#e5e5e5" }}>{tier.title}</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <span style={{ fontSize: 11, color: "#444" }}>{tier.est}</span>
                <span style={{ color: tier.color, fontSize: 16 }}>{open === tier.id ? "▲" : "▼"}</span>
              </div>
            </button>

            {/* Tier Content */}
            {open === tier.id && (
              <div style={{
                background: tier.bg,
                border: `1px solid ${tier.color}22`,
                borderTop: "none",
                borderRadius: "0 0 8px 8px",
                padding: "20px",
              }}>
                <p style={{ color: "#aaa", fontSize: 13, margin: "0 0 20px", lineHeight: 1.6 }}>
                  {tier.goal}
                </p>

                {/* Topics */}
                <div style={{ marginBottom: 20 }}>
                  <div style={{ fontSize: 10, letterSpacing: 3, color: "#555", marginBottom: 10 }}>TOPICS TO COVER</div>
                  <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
                    {tier.topics.map(t => (
                      <div key={t.id} style={{
                        background: "#ffffff08",
                        border: "1px solid #ffffff0a",
                        borderRadius: 6,
                        padding: "10px 12px",
                      }}>
                        <div style={{ fontSize: 12, fontWeight: 700, color: tier.color, marginBottom: 3 }}>
                          {t.id} {t.name}
                        </div>
                        <div style={{ fontSize: 11, color: "#666", lineHeight: 1.5 }}>{t.desc}</div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Exercises */}
                <div style={{ marginBottom: 20 }}>
                  <div style={{ fontSize: 10, letterSpacing: 3, color: "#555", marginBottom: 10 }}>EXERCISES</div>
                  {tier.exercises.map((ex, i) => {
                    const key = `${tier.id}-${i}`;
                    return (
                      <div
                        key={key}
                        onClick={() => toggle(key)}
                        style={{
                          display: "flex",
                          alignItems: "flex-start",
                          gap: 10,
                          padding: "8px 0",
                          borderBottom: "1px solid #ffffff06",
                          cursor: "pointer",
                        }}
                      >
                        <div style={{
                          width: 16,
                          height: 16,
                          border: `1.5px solid ${done[key] ? tier.color : "#333"}`,
                          borderRadius: 3,
                          background: done[key] ? tier.color + "44" : "transparent",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          flexShrink: 0,
                          marginTop: 1,
                          fontSize: 10,
                          color: tier.color,
                          transition: "all 0.2s",
                        }}>
                          {done[key] ? "✓" : ""}
                        </div>
                        <span style={{
                          fontSize: 13,
                          color: done[key] ? "#555" : "#ccc",
                          textDecoration: done[key] ? "line-through" : "none",
                          lineHeight: 1.5,
                          transition: "all 0.2s",
                        }}>{ex}</span>
                      </div>
                    );
                  })}
                </div>

                {/* Testnet */}
                <div style={{
                  background: tier.color + "11",
                  border: `1px solid ${tier.color}33`,
                  borderRadius: 6,
                  padding: "10px 14px",
                }}>
                  <span style={{ fontSize: 10, letterSpacing: 2, color: tier.color, marginRight: 8 }}>⬡ TESTNET</span>
                  <span style={{ fontSize: 12, color: "#aaa" }}>{tier.testnet}</span>
                </div>
              </div>
            )}
          </div>
        ))}

        {/* Footer note */}
        <div style={{
          marginTop: 24,
          padding: "14px 18px",
          background: "#111",
          border: "1px solid #222",
          borderRadius: 8,
          fontSize: 12,
          color: "#555",
          lineHeight: 1.7,
        }}>
          <span style={{ color: "#e5e5e5" }}>How to use this:</span> Each exercise you solve here — write the code, explain why you made the choices you did. That explanation step is non-optional. Click checkboxes as you go. Tier 3 will connect directly to your Uniswap study.
        </div>
      </div>
    </div>
  );
}