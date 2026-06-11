// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
            $$\               $$\ $$\       $$\                                       
            $$ |              $$ |$$ |      \__|                                      
 $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ |  $$\ $$\ $$$$$$$\   $$$$$$\                    
$$  _____|\_$$  _|   \____$$\ $$ |$$ | $$  |$$ |$$  __$$\ $$  __$$\                   
\$$$$$$\    $$ |     $$$$$$$ |$$ |$$$$$$  / $$ |$$ |  $$ |$$ /  $$ |                  
 \____$$\   $$ |$$\ $$  __$$ |$$ |$$  _$$<  $$ |$$ |  $$ |$$ |  $$ |                  
$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ | \$$\ $$ |$$ |  $$ |\$$$$$$$ |                  
\_______/    \____/  \_______|\__|\__|  \__|\__|\__|  \__| \____$$ |                  
                                                          $$\   $$ |                  
                                                          \$$$$$$  |                  
                                                           \______/                   
                                                                        $$\           
                                                                        $$ |          
             $$$$$$\   $$$$$$\  $$\  $$\  $$\  $$$$$$\   $$$$$$\   $$$$$$$ | $$$$$$$\ 
            $$  __$$\ $$  __$$\ $$ | $$ | $$ | \____$$\ $$  __$$\ $$  __$$ |$$  _____|
            $$ |  \__|$$$$$$$$ |$$ | $$ | $$ | $$$$$$$ |$$ |  \__|$$ /  $$ |\$$$$$$\  
            $$ |      $$   ____|$$ | $$ | $$ |$$  __$$ |$$ |      $$ |  $$ | \____$$\ 
            $$ |      \$$$$$$$\ \$$$$$\$$$$  |\$$$$$$$ |$$ |      \$$$$$$$ |$$$$$$$  |
            \__|       \_______| \_____\____/  \_______|\__|       \_______|\_______/ 
                                                                                                                                                                                                                                                                                                                                           

*/

/**
OKAY lets start first let me paste down the question: 

Tier 3 Exercise 2 — Staking with Reward Distribution
Real world context: This is the Synthetix StakingRewards contract — copied by hundreds of protocols. Every time you see "stake X, earn Y" on any DeFi protocol, this is the math underneath it.

Write a contract called StakingRewards that:

Users can stake an ERC20 token
Users can unstake their tokens anytime
Users earn reward tokens over time proportional to their stake
Users can claim their earned rewards
Owner can notify the contract of a new reward amount to distribute over 7 days

The reward math — this is the new concept:
solidity// Global tracker — increases over time
rewardPerTokenStored += (rewardRate * timePassed * 1e18) / totalStaked

// Per user — how much reward per token they're owed
rewards[user] += stakedBalance[user] * 
    (rewardPerTokenStored - userRewardPerTokenPaid[user]) / 1e18

// When reward is notified:
rewardRate = rewardAmount / 7 days
Requirements:

Two separate tokens — staking token and reward token
stake(uint256 amount) — pulls staking token from user
unstake(uint256 amount) — returns staking token to user
claim() — sends earned reward tokens to user
notifyReward(uint256 amount) — owner only, sets new reward rate
Update rewardPerTokenStored on every state change
No loops — ever

Answer on further questions i have asked:
1. Two tokens — how it works:
Yes exactly. You accept any ERC20 via interface, you give your own reward token. In real world the reward token has value because the protocol itself has value — Synthetix gives SNX as reward, people want SNX because the protocol generates real fees. For this exercise don't worry about it, just write a MockRewardToken you can mint freely for testing.

2. notifyReward and reward rate:
Think of it like a drip. Owner says "here is 7000 tokens to distribute over 7 days." The contract calculates:
solidityrewardRate = 7000 / 7 days = 1000 tokens per day
Every second, rewardRate tokens drip out to all stakers proportionally. notifyReward is just the owner telling the contract "start a new drip cycle with this amount."

3. rewardPerTokenStored:
This is the cleverest part. Instead of looping through all stakers every second — which would cost infinite gas — you track one global number that represents "total rewards earned per token staked since the beginning."
Every time anyone touches the contract it updates:
solidityrewardPerTokenStored += rewardRate * timePassed * 1e18 / totalStaked
Then per user you just track where they last "checked in":
solidity// User earned = their stake * (current global - their last checkpoint)
earned = staked[user] * (rewardPerTokenStored - lastCheckpoint[user]) / 1e18
So instead of tracking every user every second, you just track one number globally and each user has their own checkpoint. No loops needed ever.

4. No standard for staking:
Correct. There's no ERC for staking contracts. You write it as you please. The Synthetix pattern is just a widely copied design, not a standard. Your vault was missing some ERC4626 functions but for this exercise that's fine — the goal was understanding share math, not full compliance.

OKAY BEFORE I BUILD THIS I NEED TO READ ABOUT HOW THIS Synthetix StakingRewards how it works and what are its limitations.
- okay now valid undersatndable info out there i don't know if i said it but it is like mostly copied contract they all use it but it is not smt like erc or someshit like that 
- so i am going to put it my self let me see what i can do.

HOW AM I GOING TO TACKEL THIS DOWN:
 so like this is kinda hard hard means at first i don't know where to start it is blank 
 well it is besically saying create something called Synthetix StakingRewards that stake and shit and it must have this features well since i am not getting no help from any one this is how it looks like.

*/


interface IAsout3Token {
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function transfer(address _to, uint256 _amount) external returns (bool); 
    function balanceOf(address _address) external view returns (uint256);
}

error InsufficentAllowance();
error InsufficentBalance();

contract RewardToken{

    event Transfer(address indexed sender, address indexed receiver, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply; // total share.
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        owner = msg.sender;
    }

    function totalSupplies() external view returns (uint256) {
        return totalSupply;
    }
    function balanceOf(address _address) external view returns (uint256) {
        return _balanceOf[_address];
    }

    function mint(uint256 _amount, address _to) external {
        require(owner == msg.sender, "you are not the owner of this token");
        totalSupply += _amount;
        _balanceOf[_to] += _amount;
    }

    function burn(address _from, uint256 _amount) external {
        require(owner == msg.sender, "not owner");
        require(_balanceOf[_from] >= _amount, "insufficient");
        _balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        if (_balanceOf[msg.sender] < _amount) revert InsufficentBalance();

        _balanceOf[msg.sender] -= _amount;
        _balanceOf[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        if (allowance[_from][msg.sender] < _amount) revert InsufficentAllowance();
        if (_balanceOf[_from] < _amount) revert InsufficentBalance();

        allowance[_from][msg.sender] -= _amount;
        _balanceOf[_from] -= _amount;
        _balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    function checkApproval(address _owner, address _to) external view returns (bool) {
        if (allowance[_owner][_to] == 0) return false;

        return true;
    }
}

/**
now it clears up like now i know what to do this is why exercise helps this will be the foundation
for me cuz like it is not about writing the code writing the code is not the thing it is always
need arctecture design and how it will will like the math i always rush to write the code and 
end it up not good now it is clear first i need to undersatnd the maths and design it even though it is
an exercise now let me understand the math then i will design it and write it my way okay first understand okay lets start from zero


LESSON: NEVER RUSH TO WRITE A CODE FIRST UNDERSTAND WHAT YOU ARE TRYING TO DO, UNDERSTAND THE MATHS, 
        UNDERSTAND THE INCENTIVE, UNDERSTAND THE ECONOMICS, TRADEOFFS, SECURITY RISK AND OTHER WHEN YOU HAVE THE FULL PICTURE KNOW WHAT TO DO
        THEN YOU GONNA TRY TO DO AN ARCTECTURE LIKE DESIGN BASED ON WHAT YOU KNOW EVEN A LITTLE DOCUMENTATION
        THEN YOU CAN WRITE THE CODE AND WRITING THE CODE BECOME MUCH EASIER AND YOU CAN REVIEW YOUR CODE REFACTOR 
        SINCE YOU KNOW WHAT YOU ARE TRULY TRYING TO DO IT IS GOING TO BE EASY. AT LEAST LIKE KNOW WHAT YOU ARE TRYING TO DO.

 */

contract StakingRewards {
    // two tokens
    IAsout3Token public stakingToken;
    RewardToken public rewardToken;

    // reward math globals
    uint256 public rewardRate;           // tokens per second
    uint256 public lastUpdateTime;       // last time rewardPerToken was updated
    uint256 public rewardPerTokenStored; // cumulative reward per token

    // totals
    uint256 public totalStaked;

    // per user
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public userRewardPerTokenPaid; // user's last checkpoint

    constructor(address _stakingToken) {
        stakingToken = IAsout3Token(_stakingToken);
        rewardToken = new RewardToken(
            "Reward Token",
            "RT",
            18,
            0
        );
    }


    // Returns current rewardPerTokenStored including time passed since last update
    function rewardPerToken() public view returns (uint256) {
        if(totalStaked == 0) return rewardPerTokenStored;
        return rewardPerTokenStored + (rewardRate * (block.timestamp - lastUpdateTime) * 1e18 / totalStaked);
    }

    function earned(address user) public view  returns (uint256) {

    }
}
