// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.34;

/*

   █████████    ███                █████
  ███▒▒▒▒▒███  ▒▒▒                ▒▒███
 ▒███    ▒███  ████  ████████   ███████  ████████   ██████  ████████
 ▒███████████ ▒▒███ ▒▒███▒▒███ ███▒▒███ ▒▒███▒▒███ ███▒▒███▒▒███▒▒███
 ▒███▒▒▒▒▒███  ▒███  ▒███ ▒▒▒ ▒███ ▒███  ▒███ ▒▒▒ ▒███ ▒███ ▒███ ▒███
 ▒███    ▒███  ▒███  ▒███     ▒███ ▒███  ▒███     ▒███ ▒███ ▒███ ▒███
 █████   █████ █████ █████    ▒▒████████ █████    ▒▒██████  ▒███████
▒▒▒▒▒   ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒▒▒      ▒▒▒▒▒▒▒▒ ▒▒▒▒▒      ▒▒▒▒▒▒   ▒███▒▒▒
                                                            ▒███
                                                            █████
                                                           ▒▒▒▒▒

*/

/*
	OKAY LETS START TODAY WE GONNA DO MERKLE AIRDROP AND I AM EXCITED SO LETS START OKAY I AM GOING TO PASTE THE INSTRUCTION I AM GIVEN OKAY.

Tier 4 Exercise 3 — Merkle Airdrop

Real world context: This is exactly how Uniswap's UNI airdrop and Optimism's OP airdrop worked. Instead of storing thousands of addresses and amounts on-chain (which would cost a fortune in gas), you store one 32-byte hash — the Merkle root — and each user proves their own inclusion when they claim.

The core idea in one sentence:

You build a tree of hashes off-chain from a list of (address, amount) pairs. Only the tree's root goes on-chain. When a user wants to claim, they submit their own data plus a "proof" — a small set of hashes — and the contract recombines them to check if it reconstructs the same root. If it does, they're proven to be in the original list, without the contract ever storing the full list.

Write a contract called MerkleAirdrop:

Constructor takes a bytes32 merkleRoot and an ERC20 token address
claim(uint256 amount, bytes32[] calldata proof) — user calls this to claim their tokens
Inside claim:
Reconstruct the leaf: keccak256(abi.encodePacked(msg.sender, amount))
Walk through the proof array, hashing the running result with each proof element (in the correct sorted order) until you get a final hash
Compare that final hash to the stored merkleRoot — if it matches, they're verified
Check they haven't already claimed — a mapping(address => bool) claimed
Transfer them amount tokens

The hashing logic you need to implement yourself:

solidity
function verify(bytes32[] calldata proof, bytes32 leaf) internal view returns (bool) {
    bytes32 computedHash = leaf;
    for (uint256 i = 0; i < proof.length; i++) {
        bytes32 proofElement = proof[i];
        if (computedHash <= proofElement) {
            computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
        } else {
            computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
        }
    }
    return computedHash == merkleRoot;
}

I'm giving you this because the sorted-pair hashing convention is a strict standard (OpenZeppelin's MerkleProof library uses this exact ordering) — deviating from it means your tree generation script (which you'd write off-chain, not required for this exercise) wouldn't match. Understand why each line does what it does rather than deriving the algorithm from scratch.

What you actually need to write yourself:

The claim() function — the checks, the claimed mapping, the token transfer, calling verify()
Custom errors for already claimed and invalid proof
The constructor
An event for successful claims

Before coding — explain in your own words: why does hashing pairs together repeatedly, walking up the proof array, let you prove membership in a huge list using only a handful of hashes, instead of needing the whole list on-chain?

*/

/*
	okay lets start mmmm where do i begin

	so i am also required to explain things in word right so as i always do and say writing the code is the last part of this job so i am going to explain and make things clear alrighty okay so lets start
	so okay let me list out what i am required to do and i will start with answering them.

	i am required to code this:

	What you actually need to write yourself:

	* The claim() function — the checks, the claimed mapping, the token transfer, calling verify()
	* Custom errors for already claimed and invalid proof
	* The constructor
	* An event for successful claims

	and before coding i am required to explain this:

	explain in your own words:
	why does hashing pairs together repeatedly,
	walking up the proof array,
	let you prove membership in a huge list using only a handful of hashes, instead of needing the whole list on-chain?

	1. Okay i am going to start with the explaining in word right so lets start.
	the first one says why does hashing pairs together repeatedly- so here it how the merkel proof works we gona collect user raw data and hash them spearatly and those hashed user data which we refer it as L and user data inputs are hashed.
	then those hashed data are going to add together like we can take two of those together like two user data hashes like P1 = hash(L1 + L2)  and P2 = hash(L3 + L4) and it goes like that and those get hases into this
	the next part is like this is not like must next part it is like for example so it is short in real life data to reach the root has they goona get hashed a lot of times okay so the next part is
	we reach the root hash by R = hash(P1 + P2) so we reached the root which we use to check for the inculsion so to reach the root we gonna have to has it a lot of times that why we do it okay.

	2. i didn't really get what the fuck walking up the proof array i don't really get what does it mean but i feel like i answered it with the first question. i believe.
	3. the question is not clear but let me answer the question as i understand it okay. so like yes instead of holding a whole data on chain we use this to proof for inclusion so yes
	we hash then till we reach the root and we use the root hash to proof the inclusion right that is how we do it if it wheren't for this it is going to be super expensive and slow because holding a lot of data on chain is like i don't know what to say
	a perfect way to waste money right so it is good way that they have found nice.


	OKAY NOW ABOUT THE CODE
	let me bring the code requirement again:

	* The claim() function — the checks, the claimed mapping, the token transfer, calling verify()
	* Custom errors for already claimed and invalid proof
	* The constructor
	* An event for successful claims

	so ya i saw like code glossary from like cyfrin website so like writing the code is easier now and also since it not that much of complicated thing so like
	let me try it and like write the draft like the skeleton right if it where real prod or whatever what i would do is like first i am going to design the architecture and like
	and like write the required function and try to explain what they do from the perspective it is way easier to write the it on like paper and also like try to get what you need and
	write a doc then you gonna implement it then like see thing and try to like update the document and grow like you don't have to just wake up and write random code okay.

	lets start coding.

*/

/*
    AS ALWAYS THIS IS NOT A PRODUCTINO CODE I DON'T KNOW WHY I AM SAYING THIS AND ALSO
    LIKE IN REAL PROD WE USE OPENZEPPLINE LIBRARIES AND SHIT FOR THAT AND THIS IS LIKE VERY VERY LITTLE
    GLIMPS OF IT LIKE VERY SHORT VERY LITTLE PART OF IT OKAY AND ALSO IT IS NOT PERFECTLY DONE I JUST DO IT IN A WAY
    OF LIKE THE EXERCISE REQUIRES ME TO DO SO THAT IS HOW IT IS DONE OKAY SO YA IT IS JUST A NOTICE FROM ME.


*/

//okay let me try to explain and i know i am not using params but like i will use them later in prod for time efficiency i need to get this done fast so i am just gonna comment them okay.

// errors
error AlreadyClaimed();
error InvalidProof();

// interface
interface IERC20 {
     function transfer(address to, uint256 amount) external returns (bool);
}

contract MerkelAirdrop {
    event Claim(address indexed to, uint256 amount);

    address public immutable token;
    bytes32 public immutable root;
    mapping(address => bool) public claimed;

    constructor(bytes32 _root, address _token) {
        token = _token;
        root = _root;
    }

    // so like this is like to get leaf hash so as we all know we use our leaf hash to check with the root which is required to check
    // getting this is super important
    function getLeafHash(address to, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(to, amount));
    }

    // this is claim function which i am ordered to do
    function claim(bytes32[] calldata proof, uint256 amount) external {
        // get the leaf at first
        bytes32 leaf = getLeafHash(msg.sender, amount);

        // then this like i don't really understand how to use the vertify i just use it like this it returns bool if it returns bool that means it works it proofs so i take true as a yes then do my shit.
        bool truth = verify(proof, leaf);

        // check if it is already claimed.
        if (claimed[msg.sender]) revert AlreadyClaimed();
        if(!truth) revert InvalidProof();

        // do my shit if it proofs
        if (truth) {
            claimed[msg.sender] = true;
            bool success = IERC20(token).transfer(msg.sender, amount);
            require(success, "transfer failed");

            emit Claim(msg.sender, amount);
        }
    }

    // this is the vertify function that vertifeis it it starts from the leaf and goes to the root it uses
    // loop to go all they way and check it at the end it gives us a bool
    function verify(bytes32[] calldata proof, bytes32 leaf) internal view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}

