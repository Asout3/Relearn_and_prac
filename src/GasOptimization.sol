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

/* THIS IS NOT OPTIMIZED VERSION OF THE CODE

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
error ItISPaused();
error FeeExceedsHundred();

contract RewardVault {
    // i don't really like all of this variables
    // it was today that i learned the order of variables affect the gas cost right i can't belive that is real but i think it is true so ya
    // it goes like 1 slote is 32 byte so you can put as much variable as you can in one variable so this showes that solidity compils top to down so if you fuck up the order it puts then in like different slot so we need to try to put them like in a proper way all small byte got into one slot
    uint256 public totalDeposits;

    address public owner;
    address public token;

    bool public paused;
    uint8 public feePercent;
    // unused variable
    //uint256 public lastUpdate;
    //bool public emergencyMode;

    mapping(address => uint256) public balances;
    //mapping(address => bool) public isVIP;

    struct UserInfo {
        uint256 deposited;
        uint256 lastDepositTime;
        bool active;
        //address referrer; unused variable
        //uint8 tier; unused variable
    }

    mapping(address => UserInfo) public userInfo;

    constructor(address _token) {
        owner = msg.sender;
        token = _token;
    }

    modifier onlyOwner() {
        //require(msg.sender == owner, "Caller is not the owner of this contract");
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function deposit(uint256 amount) external {
        // this can be custom errors
        //require(amount > 0, "Amount must be greater than zero for a deposit to work");
        //require(!paused, "The contract is currently paused, try again later");

        if (amount <= 0) revert ZeroAmount();
        if (paused) revert ItISPaused();

        UserInfo storage user = userInfo[msg.sender];

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender] = balances[msg.sender] + amount;
        //userInfo[msg.sender].deposited = userInfo[msg.sender].deposited + amount;
        //userInfo[msg.sender].active = true;
        //userInfo[msg.sender].lastDepositTime = block.timestamp;

        // i know this cuz i was give a hint by other ai and it reduced gas really i never knew we can do thsi
        // i used to think like the storage thing will cost more but this one is better we don't do sload so like this one is better
        // good to know now ever time if i have to use same the same mapping log of time i will use this method.
        user.deposited = user.deposited + amount;
        user.active = true;
        user.lastDepositTime = block.timestamp;

        totalDeposits = totalDeposits + amount;
    }

    function withdraw(uint256 amount) external {
        // custom errors are gas inefficent
        //require(balances[msg.sender] >= amount, "Insufficient balance to withdraw this amount");
        //require(amount > 0, "Amount must be greater than zero");

        if (balances[msg.sender] < amount) revert InsufficientBalance();
        if (amount <= 0) revert ZeroAmount();

        UserInfo storage user = userInfo[msg.sender];

        balances[msg.sender] = balances[msg.sender] - amount;
        //userInfo[msg.sender].deposited = userInfo[msg.sender].deposited - amount;
        user.deposited = user.deposited - amount;
        totalDeposits = totalDeposits - amount;

        IERC20(token).transfer(msg.sender, amount);
    }

    // no we don't use memory we use calldata so fucking fix it
    function batchCheckActive(address[] calldata users) external view returns (bool[] memory) {
        bool[] memory results = new bool[](users.length);
        // do u think this will overflow if not lets use unchecked if the loop is important and there is no other way of doing it
        // i don't know if this is real prod they need to find better design this is not effective since this is exercise only i will try to make it like uncheked but like this kind of design is not acceptable
        // this is huge risk right so like so like this is exercise so i won't go deep dive but i know that this probably won't work right so i will give it a chave for this exercise right so like i won't waste my time in this
        unchecked {

            for (uint256 i; i < users.length; ++i) {
                results[i] = userInfo[users[i]].active;
            }
        }
        return results;
    }

    function getUserSummary(address user) external view returns (uint256, bool, uint256) {
        return (userInfo[user].deposited, userInfo[user].active, balances[user]);
    }

    function setFee(uint8 _fee) external onlyOwner {
        // custom errors
        //require(_fee <= 100, "Fee cannot exceed 100 percent obviously");
        if (_fee > 100) revert FeeExceedsHundred();
        feePercent = _fee;
    }

    function pause() external onlyOwner {
        paused = true;
    }
}

/*
OKAY LETS THINK. WAIT FIRST LET ME READ THE INSTRUCTIONS.
okay now i have read the instruction now let me read the contract and understand it.
okay it is basic RewardVault function okay i think it is good challange as i read it i didn't really saw much of like gas optimization idea but i think it is my job to reaserach and remeber and come up with a solution.

wait i did it any way i got it so like i optimized it as best as i can i asked ai like to give me hint i do the first round and asked like other ai if there is soemthing hidden it give me hints and i leanred alot from it really wow the more i know like the more i relaise that i don't know shit and i need to learn more so ya.
*/