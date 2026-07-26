// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/*

  ________
 /  _____/_____    ______
/   \  ___\__  \  /  ___/
\    \_\  \/ __ \_\___ \
 \______  (____  /____  >
        \/     \/     \/
                   __  .__        .__                __  .__
      ____ _______/  |_|__| _____ |__|____________ _/  |_|__| ____   ____
     /  _ \\____ \   __\  |/     \|  \___   /\__  \\   __\  |/  _ \ /    \
    (  <_> )  |_> >  | |  |  Y Y  \  |/    /  / __ \|  | |  (  <_> )   |  \
     \____/|   __/|__| |__|__|_|  /__/_____ \(____  /__| |__|\____/|___|  /
           |__|                 \/         \/     \/                    \/


*/

/*	THIS IS GAS OPTIMIZATION CONTRACT WHERE THE EXERCISE GIVE ME A CONTRACT AND I WILL TRY TO OPTMIZE ITS GAS CONSUMPTION
THIS WILL BE GOOD EXPRINANCE AND LEARNING WAY I HAVE LEARNED LIKE ASSEMBLY AND YUL LIKE IN CYRFIN I KNOW IT COULD HELP ME I TRY MY BEST TO
DO IT AND ALSO LIKE THIS PRACTICE WHERE YOU TRY TO OPTIMIZE THE GAS COST IT SHOULD BE THE TOP CONSIDERATION WHEN I WRITE CONTRACTS
WE SHOULD CONSIDER SECURITY AND GAS BECAUSE THEY ARE REALLY IMPORTANT THEY COULD KILLS ONES PROTOCOL SO EVERY TIME I WRITE A CONTRACT
I MUST GIVE A TIME FOR GAS OPTIMIZATION WHEN I WRITE IT I TRY TO MAKE IT AS MUCH AS GAS OPTIMIZED AND ALSO WHEN I FINISH WRITING IT I SHOULD GIVE A TIME
FOR GAS OPTIMIZATION AND ALSO FOR SECURITY CHECK WELL I CAN'T NOT STRESS MORE ABOUT SECURITY IT IS ANOTHER TOPIC BUT IT IS LIKE REALLY CORE OF IT SINCE NOW
WE ARE TALKING ABOUT GAS THERE NEED TO BE TIME ALLOCATED FOR GAS OPTIMIZATION.
*/

/*

THIS IS THE QUESTION: I AM ASKED TO OPTIMIZE THE GAS OF A CONTRACT I WAS GI

Go through this checklist and apply what's relevant:

1. Storage packing
Look at your struct and state variable declarations. Solidity packs variables into 32-byte slots. If you have a bool, uint8, and address declared separately with other unrelated variables between them, they each waste a full slot. Reorder so same-slot-eligible variables sit next to each other.

2. Cache storage reads
Any time you read the same storage variable more than once in a function, cache it into a local variable first:

solidity
// ❌ Two SLOADs
if(balances[msg.sender] > 0) {
    uint256 amount = balances[msg.sender];
}

// ✅ One SLOAD
uint256 bal = balances[msg.sender];
if(bal > 0) {
    uint256 amount = bal;
}

3. Use calldata instead of memory for external function parameters
If a function is external and takes an array or string it doesn't modify, calldata avoids an unnecessary copy.

4. Unchecked blocks for safe arithmetic
Any loop counter increment where overflow is impossible — wrap it in unchecked.

5. Custom errors over require strings
If any require(x, "long string") remain, custom errors are cheaper — you likely already know this, just audit for leftovers.

6. Short-circuit conditions
Order your && and || checks so the cheapest/most-likely-to-fail check runs first, avoiding unnecessary computation on the rest.

What to submit:

Pick one contract, go through it function by function, and for each change you make, comment the before/after and why it saves gas. You don't need exact gas numbers — Remix will show you relative differences if you want to check, but the reasoning is what matters here.

Go through it and come back with your optimized version.

*/

// AS I SAID BEFORE THE CODE BELOW IS AI GENERATED WHICH FOR ME TO OPTIMIZE ITS GAS OKAY SO I DIDN'T WRITE IT I COULD LIKE
// TAKE MY OTHER EXERCISE CONTRACT BUT IT GOT TO BE AI GENERATED CUZ INORDER FOR ME TO KNOW MORE THE AI SHOULD LIKE PUT SOME REALLY GOOD CONCEPTS AND LIKE PUT A LOT OF THEM IN IT RIGHT.

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

error ZeroAmount();
error InsufficientBalance();
error NotOwner();

contract RewardVault {
    address public owner;
    bool public paused;
    uint256 public totalDeposits;
    address public token;
    uint8 public feePercent;
    uint256 public lastUpdate;
    bool public emergencyMode;

    mapping(address => uint256) public balances;
    mapping(address => bool) public isVIP;

    struct UserInfo {
        uint256 deposited;
        bool active;
        uint256 lastDepositTime;
        address referrer;
        uint8 tier;
    }

    mapping(address => UserInfo) public userInfo;

    constructor(address _token) {
        owner = msg.sender;
        token = _token;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner of this contract");
        _;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero for a deposit to work");
        require(!paused, "The contract is currently paused, try again later");

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender] = balances[msg.sender] + amount;
        userInfo[msg.sender].deposited = userInfo[msg.sender].deposited + amount;
        userInfo[msg.sender].active = true;
        userInfo[msg.sender].lastDepositTime = block.timestamp;

        totalDeposits = totalDeposits + amount;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance to withdraw this amount");
        require(amount > 0, "Amount must be greater than zero");

        balances[msg.sender] = balances[msg.sender] - amount;
        userInfo[msg.sender].deposited = userInfo[msg.sender].deposited - amount;
        totalDeposits = totalDeposits - amount;

        IERC20(token).transfer(msg.sender, amount);
    }

    function batchCheckActive(address[] memory users) external view returns (bool[] memory) {
        bool[] memory results = new bool[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            results[i] = userInfo[users[i]].active;
        }
        return results;
    }

    function getUserSummary(address user) external view returns (uint256, bool, uint256) {
        return (userInfo[user].deposited, userInfo[user].active, balances[user]);
    }

    function setFee(uint8 _fee) external onlyOwner {
        require(_fee <= 100, "Fee cannot exceed 100 percent obviously");
        feePercent = _fee;
    }

    function pause() external onlyOwner {
        paused = true;
    }
}

/*
OKAY LETS THINK. WAIT FIRST LET ME READ THE INSTRUCTIONS.
okay now i have read the instruction now let me read the contract and understand it.

*/