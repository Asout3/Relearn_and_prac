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

        - And it will save you a lot of hours fight bugs.

        
 */

 /**
 okay lets start i am going to break this shit down and like try to understand this thing
 okay i will try to understand from the core the thing is we the idea is there is this stalk and reward thing
 which the user profit from stalking here is the basic math

 I WILL CONTINUE THAT WHEN I GET BACK ON THE NEXT SESSION.

so what i am going to do is go and read and understand as much as possible i don't want stupid ai explantion. 
  okay updates i couldn't find shit there is no proper information on the interent that could be understandable they all short and not proper and doesn't even care to explain the maths
  so i going to ask ai to explain it to me for further understanding.
  

- okay this is what i know so far: 
so synthix reward staking is a stake and get reward game you stake and you get rewared based on the stake. i don't really know where the stake comes from like i don't know the system invest it or smt else but what i know is like the get proffit the owner distribute the money.
and we accept an erc20 and we give an erc20 token back as a reward token it is also erc20

so let me dive into the arctecture so this kind of contracts doesn't really have an erc or something like that they just copy one another and use it so i will try to make this one as best as possible also from the instruction and what i read.

so let me explain this thing the main thing important part is like the 'rewardPerTokenStored' the reason we use that is instead of updating each user state we can like use this variable to track how much reward per token get like for each token how much reward it gets
so like if we use loop to update each user state the contract will be unuseable for gas reason and also eventuall stop working for the case of dos cuz it will use more gas than ethereum want it so it will be dos and if that didn't happen if we allow a lot of gas it will be expensive and no one will use it so this is genius.
let me explain to you how the 'rewardPerTokenStored' works so every time the state change like when we do some action that changes the state of the stake we put our rewardPerToken and here is how it works

rewardPerToken += (rewardRate * timePassed * 1e18) / totalStaked 

so it means add to rewardPerToken :  
rewardRate means how much toekn we give per day like the reward rate per day or per minute or sec.
timePassed means how much time passed like how many reward where given like it is kinda last updated time.
1e18 is like solidity doesn't have decimal so like we use that to neutalize it 
totalStaked is like total amount of staked token

so as i told you the use of this reward per token is like it gives us how much reward per a token gets if you have one token how much reward would that get.

so like for this image to form up let me add one other core feature and like it is going to give the full picture and you understand how it works
so remeber the core thing is that stake and reward distribution based on how much you staked and to give you how much you earned i showed you the first step which is rewardPerToken.
the second most important part is the userRewardPerTokenPaid this is also important thing also why we use it to calculate how much let me answer that.
we use userRewardPerTokenPaid to track the rewardPerToken of that user what i mean is like so every time rewardPerToken is updated so like and since it is updated every time we don't want to give new
comers the reward they don't really owe so we use rewardPerToken as a timestamp typeshit so like we put when ever they join like when ever they join we add to their name the current reward per token let me show you example.
example: 
current staked amount = 200
current reward per toekn = 3

so alice got in to day
she provide 100 amount to stake so the current staked amount is 300
the userRewardPerTokenStored[alice address] = 3

so lets say 2 or 3 days passes more reward distributed those days.
lets say the staked amount is like = 500 // other people got in also
current reward per token = 6

so alice wants to cliam this is where the magic happens when she hit cliam this is what happens
it calculates 
amount of reward to claim = stakedBalance[alice] * (rewardPerTokenStored - userRewardPerTokenPaid[alice]) / 1e18 // for precsison.
 aortw or rewards[user] = (6 - 3) * 100 // lets try to forget the 1e18 for now okay.
 = 3 * 100
 = 300 reward tokens   so all this goes to the mapping rewards[] i will explain how the reward works soon.

and also after we finish this calcuation we need to updates state whic his like userRewardPerTokenPaid[alice] = current rewardPerTokenStored.

 NOTE: so i may have said things updates constantly but no smart contract can't intialize them self by their own so someone need to intereact with them so when ever someone intereact with them so we updates state whenever someone intereact with them.

so now let me talk about the reward system.

okay i am back lets continue so like i will explain about the reward system which is like the last part and the most important thing so ya lets start.
so the reward system works like in the contract the owner deposite the amount to distribute on the contract so like we can check it using like balanceOf(address(this)) so 
after the owner deposite they call notifyReward(uint256 amount) so like the amount of reward token he wants to distribute this week.
so like after it gets notified we gonna calcuate the rewardRate so like this reward rate counts like per second so we gonna add a lot of second in it so it will be like day it is like the system it only count seconds so nothing we can do about it okay so it will be like 86400 seconds.
so the formual is like 
    rewardRate = rewardAmount / 7 days  so like it will be the notified amount / 86400 * 7 seconds
    so like this rewardRate formula is like in the notify reward function so like we use that and it is good
    and what i want to stress is like the smart contract update it self so like when ever someone interact it does all the updates like like update the whole thing then it does it works.
    so after we calcualte the like the notify reward so we use rewardRate every where we want like in the formulas
    like we use here:
    rewardPerTokenStored += (rewardRate * timePassed * 1e18) / totalStaked  //you can see it and every where
    so like we update every time some one interact like update the time like lastUpdateTime.
    so also like let me talk a little about the reward[user] mapping so we put the amount of reward that a person can claim and we clean it up after they finish so that is how we use it.

    one important thing left why do we use like why do we use lastUpdateTime so let me clarify that so we use it cuz as i said and you know smart contracts can't intialize them self unless someone calls them the don't wake up
    so the reward is calcualted could be wrong if it didn't updated right like if someone didn't intereact for like 2 or 3 days we don't know when was the time it was updated so like we don't know how much reward to like diversify 
    so user lastUpdatedTime so like we could track when was the last time updated then we gonna be able to calculate how much it need to give and do based on our formula so it is importnat

    so that is what i belive i need to explain next i will start the coding part and i will write as much comment and as best quility code as possible thank you.
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
