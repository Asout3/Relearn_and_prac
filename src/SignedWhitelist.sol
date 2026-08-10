// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.34;

/*

  _________.__                         ._____      __.__    .__  __         .__  .__          __   
 /   _____/|__| ____   ____   ____   __| _/  \    /  \  |__ |__|/  |_  ____ |  | |__| _______/  |_ 
 \_____  \ |  |/ ___\ /    \_/ __ \ / __ |\   \/\/   /  |  \|  \   __\/ __ \|  | |  |/  ___/\   __\
 /        \|  / /_/  >   |  \  ___// /_/ | \        /|   Y  \  ||  | \  ___/|  |_|  |\___ \  |  |  
/_______  /|__\___  /|___|  /\___  >____ |  \__/\  / |___|  /__||__|  \___  >____/__/____  > |__|  
        \/   /_____/      \/     \/     \/       \/       \/              \/             \/        

*/



// ALRIGHT LETS START 

/*
Tier 4 Exercise 4 — EIP-712 Signed Whitelist

Real world context: This is how OpenSea's lazy minting and Uniswap's Permit2 work. Instead of a user paying gas to call approve() or get whitelisted on-chain, they just sign a message off-chain (free, instant, in their wallet) — and later, someone submits that signature on-chain to prove the user authorized something, without the user ever sending a transaction themselves.

The core idea in one sentence:

A trusted signer (like a project owner) signs a message off-chain saying "this address is allowed to do X." The user brings that signature to the contract. The contract mathematically recovers who signed it from the signature itself, checks that it matches the trusted signer, and if so, treats the user as authorized — with zero gas cost paid by the signer.

Why EIP-712 specifically, not just any signed message:

A raw signed message is just signed bytes — hard to display meaningfully in a wallet, and easy to accidentally reuse across different contracts or contexts. EIP-712 defines a structured, typed format for what gets signed, so wallets like MetaMask can show the user exactly what they're signing in a readable way, and so a signature for "whitelist me on Contract A" can never be replayed on Contract B.

Write a contract called SignedWhitelist that:

Has a trusted signer address, set in the constructor
Has a function claim(uint256 amount, bytes calldata signature) — the user calls this themselves, but the authorization came from the signer's off-chain signature
Recovers the signer from the signature using ecrecover
If the recovered address matches the trusted signer, the user is allowed to claim
Tracks who has already claimed — one claim per address
Custom errors for invalid signature and already claimed

The EIP-712 domain and type hashing — I'll give you this boilerplate, since it's a strict standard you'd copy from a reference in real work:

solidity
bytes32 public constant DOMAIN_SEPARATOR = keccak256(
    abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes("SignedWhitelist")),
        keccak256(bytes("1")),
        block.chainid,
        address(this)
    )
);

bytes32 public constant CLAIM_TYPEHASH = keccak256("Claim(address user,uint256 amount)");

function getMessageHash(address user, uint256 amount) public view returns (bytes32) {
    bytes32 structHash = keccak256(abi.encode(CLAIM_TYPEHASH, user, amount));
    return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
}

What you write yourself:

The constructor, setting signer
claim(uint256 amount, bytes calldata signature) — calls getMessageHash, then recovers the signer from the signature and message hash, checks it matches signer, checks not already claimed, marks claimed, does whatever "claiming" means for this exercise (just emit an event, no token transfer needed)
Splitting the signature into v, r, s components and calling ecrecover — you'll need to look up the standard way to split a 65-byte signature into these three values, since it's a fixed, mechanical pattern
Custom errors

Before coding — explain in your own words: why can't the user just fake a signature themselves, and why does recovering the same address every time from a valid signature actually prove the signer authorized this specific claim?

Go.



AS ALWAYS LET ME FIRST TRY TO UNDERSTAND THE QUESTION.

I ADMIT THAT THIS IS THE HARDEST ONE SO FAR REALLY I DON'T REALLY KNOW WHAT I AM LOOKING FOR WHAT I AM SUPPOSED TO DO AND HOW I AM GOING TO DO IT IT IS KINDA COMPLEXT NO DIRECT VISOIN AND I AM NOT TRIANED LIKE NEVER PRACTICED FOR THIS SHIT BUT I WILL TRY.

okay let me answer the asked question here are they:

1. why can't the user just fake a signature themselves
2. why does recovering the same address every time from a valid signature actually prove the signer authorized this specific claim?

 so so like as i let me answer the first question which is why can't they fake it, it is because if they change just a little thing it would work it give other thing which will which it doesn't work so trying to touching it won't work.

 --- clearer version of my answers (so i actually get this):

 1. Why can't the user just fake a signature?

    A signature is made with the signer's PRIVATE KEY. The user does not have that key.
    ecrecover takes (messageHash, signature) and gives back the address whose private key
    produced that signature. If the user invents random bytes, ecrecover either fails
    (address(0)) or recovers SOME random address — but not our trusted signer address.
    So the check `recovered == signer` fails. You can't "guess" a valid signature for
    someone else's key without the private key. Changing even 1 bit of a real signature
    or of the message makes recovery point to a different address.

 2. Why does recovering the same address prove the signer authorized THIS claim?

    The message hash is NOT just "yes whitelist me". It is built from:
      - domain (this contract, this chain, name "SignedWhitelist")
      - the specific user address
      - the specific amount
    So the signer signed "user X can claim amount Y on THIS contract on THIS chain".
    ecrecover only returns the signer's address if the signature was made over THAT exact hash.
    If the user changes amount, or someone tries the signature on another contract/chain,
    the hash is different → recovery either fails or is not our signer → claim reverts.
    Same recovered address every time for a valid (message, signature) pair is just how
    ECDSA works: one private key always maps to one address.

  FLOW OF THIS WHOLE THING (so i can see it):

    OFF-CHAIN (free, no gas):
      trusted signer has private key
      signs EIP-712 message: Claim(user = alice, amount = 100)
      gives alice the 65-byte signature

    ON-CHAIN (alice pays gas):
      alice calls claim(100, signature)
      contract rebuilds the same message hash for (msg.sender, 100)
      splits signature into v, r, s
      ecrecover → recovered address
      if recovered == trustedSigner AND alice not claimed yet → mark claimed, emit event

*/


/*
    AS ALWAYS THIS IS NOT PRODUCTION CODE.
    IN REAL PROD YOU'D USE OpenZeppelin ECDSA / EIP712 helpers.
    THIS IS THE EXERCISE VERSION — LEARN THE MECHANICS.
*/


contract SignedWhitelist {
    // custom errors
    error InvalidSignature();
    error AlreadyClaimed();

    event Claimed(address indexed user, uint256 amount);

    // the trusted off-chain signer (project owner / backend wallet)
    address public immutable signer;

    // one claim per address
    mapping(address => bool) public claimed;

    // EIP-712 type hash for Claim(address user, uint256 amount)
    // this is a pure compile-time constant — fine as constant
    bytes32 public constant CLAIM_TYPEHASH = keccak256("Claim(address user,uint256 amount)");

    // NOTE: the exercise wrote DOMAIN_SEPARATOR as `constant`, but Solidity constants
    // must be known at compile time. `block.chainid` and `address(this)` are only known
    // at deploy time, so we set it once in the constructor as `immutable` instead.
    // Same math as the exercise — just correct Solidity.
    bytes32 public immutable DOMAIN_SEPARATOR;

    constructor(address _signer) {
        signer = _signer;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("SignedWhitelist")),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    // builds the EIP-712 digest the signer was supposed to sign
    // step 1: hash the struct Claim(user, amount)
    // step 2: wrap with "\x19\x01" + domain + structHash  (EIP-712 final digest)
    function getMessageHash(address user, uint256 amount) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(CLAIM_TYPEHASH, user, amount));
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    }

    // user calls this with the amount + the signature the trusted signer gave them off-chain
    function claim(uint256 amount, bytes calldata signature) external {
        // already claimed? no second claim
        if (claimed[msg.sender]) revert AlreadyClaimed();

        // rebuild the exact hash the signer signed for (THIS user, THIS amount)
        bytes32 messageHash = getMessageHash(msg.sender, amount);

        // recover who signed it
        address recovered = recoverSigner(messageHash, signature);

        // must be our trusted signer (also reject address(0) which means bad sig)
        if (recovered == address(0) || recovered != signer) revert InvalidSignature();

        // effects
        claimed[msg.sender] = true;

        // for this exercise "claiming" just means we emit — no token transfer needed
        emit Claimed(msg.sender, amount);
    }

    // split 65-byte signature into v, r, s then call ecrecover
    // layout of a standard ECDSA signature:
    //   bytes 0..31  → r  (bytes32)
    //   bytes 32..63 → s  (bytes32)
    //   byte  64     → v  (uint8, usually 27 or 28)
    function recoverSigner(bytes32 messageHash, bytes calldata signature) internal pure returns (address) {
        // must be exactly 65 bytes or it's garbage
        if (signature.length != 65) revert InvalidSignature();

        bytes32 r;
        bytes32 s;
        uint8 v;

        // assembly is the standard mechanical way to unpack the 65 bytes
        // (you can also use signature[0:32] slicing in newer solidity, same idea)
        assembly {
            // signature is calldata: first 32 bytes at the pointer are length,
            // actual data starts 32 bytes after the pointer
            r := calldataload(signature.offset)
            s := calldataload(add(signature.offset, 32))
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        // some wallets use v = 0/1 instead of 27/28 — normalize
        if (v < 27) {
            v += 27;
        }

        // ecrecover returns the address that signed messageHash, or address(0) on failure
        return ecrecover(messageHash, v, r, s);
    }
}
