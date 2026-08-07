// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

//   ╦ ╦╦ ╦╔═╗╔═╗
//   ║ ║║ ║╠═╝╚═╗
//   ╚═╝╚═╝╩  ╚═╝

/*
    ALRIGHT LADIES LETS DO THIS

    HERE IS THE QUESTION:

Tier 4 Exercise 2 — UUPS Upgradeable ERC20

Real world context: Most production tokens use UUPS proxies so the team can fix bugs or add features without users migrating to a new address. Your balance stays at the same address forever — but the logic behind it can change.

The core concept:

A Proxy contract holds all the actual storage but has almost no logic — every call gets forwarded via delegatecall to a separate Implementation contract that holds the logic.

delegatecall runs the implementation's code, but using the proxy's storage. So when transfer() executes, it's the implementation's function code running, reading and writing the proxy's storage slots, not its own.

To "upgrade," you deploy a new implementation (V2) and point the proxy at it. Storage stays exactly where it was — only the logic pointer changes.

Write three contracts:

1. TokenV1 — basic ERC20 (name, symbol, balances, transfer, approve, transferFrom), structured for upgradeability:

No constructor — use an initialize() function instead, since proxies can't run constructors on their own storage
Guard so initialize() can only be called once — a bool initialized flag works

2. TokenV2 — same as V1, plus one new feature: mint(address, uint256), owner only. This proves the upgrade actually added capability.

3. Proxy — the storage-holding contract:

solidity
contract Proxy {
    address public implementation;
    address public admin;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    function upgrade(address _newImplementation) external {
        require(msg.sender == admin, "not admin");
        implementation = _newImplementation;
    }

    fallback() external payable {
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

This assembly is boilerplate — copy it, focus on understanding what each line does rather than deriving it yourself.

Critical rule: Storage layout in V1 and V2 must match — same variable order, same types. Only add new variables at the end in V2, never in the middle, or you corrupt existing user data.

Before writing any code — explain in your own words: why does delegatecall let the proxy keep the implementation's logic but use its own storage? What would break if you used a regular call instead?


*/

/*

    i wrote the code and it kidna like okay but i didn't write a the code for proxy but like i will try to read and explain it okay so ya
    first lets me start with the question the ai asked me to explain which is :

    why does delegatecall let the proxy keep the implementation's logic but use its own storage? What would break if you used a regular call instead?

    okay let me say something about the delegatecall, from what i have read the delegagtecall works because it uses its own storage like we have proxy contract and we have logic contract when we inteact
    the proxy contract uses delegate call to like use logic contract logic and it uses proxy storage and that is why when the logic contract changes the address and othe shit stays the same the proxy contract doesn't change which holds the storage
    and that is why we use delegatecall it kinda redirect to other logic while still using the same logic it is like we can use this analogy which is it is like a student cheating on his exam where it goes like
    the proxy is the student which cheats which gets the answer from other student the other student which provide the answer is the logic or implementation contract so the best part is the student which cheat copy the answer from the good student and write it on its own exam paper which as the proxy does which it writes on its own storage slot.

    the other question is like what is wrong with call, so we don't use call because it uses the logic or implementation contract storage so it doesn't work so it is besically no change if we were to use the logic contract storage there will be no use for the proxy and when we update or change we need to like use or adpt new storage new address and shit so it is no go. so that is why we use delegatecall.

*/

//  ░▀█▀░█▀█░█░█░█▀▀░█▀█░░░█░█░▀█░
//  ░░█░░█░█░█▀▄░█▀▀░█░█░░░▀▄▀░░█░
//  ░░▀░░▀▀▀░▀░▀░▀▀▀░▀░▀░░░░▀░░▀▀▀
error AlreadyInitialized();
error InsufficentAllowance();
error InsufficentBalance();
error NotOwner();

contract tokenV1 {
    event Transfer(address indexed sender, address indexed receiver, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    bool public called;

    mapping(address => uint256) internal _balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    modifier onlyOnce() {
        if (called) revert AlreadyInitialized();
        _;
    }

    function initialize(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply)
        public
        onlyOnce
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _balanceOf[msg.sender] = _totalSupply;
        called = true;
    }

    function totalSupplies() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return _balanceOf[_address];
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        if (balanceOf(msg.sender) < _amount) revert InsufficentBalance();

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
        if (balanceOf(_from) < _amount) revert InsufficentBalance();

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

//   ░▀█▀░█▀█░█░█░█▀▀░█▀█░░░█░█░▀▀▄
//   ░░█░░█░█░█▀▄░█▀▀░█░█░░░▀▄▀░▄▀░
//   ░░▀░░▀▀▀░▀░▀░▀▀▀░▀░▀░░░░▀░░▀▀▀

contract tokenV2 {
    event Transfer(address indexed sender, address indexed receiver, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    bool public called;
    address public owner;

    mapping(address => uint256) internal _balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    modifier onlyOnce() {
        if (called) revert AlreadyInitialized();
        _;
    }

    modifier onlyOwner() {
        if (owner != msg.sender) revert NotOwner();
        _;
    }

    function initialize(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply)
        public
        onlyOnce
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _balanceOf[msg.sender] = _totalSupply;
        called = true;
        owner = msg.sender;
    }

    function totalSupplies() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _address) public view returns (uint256) {
        return _balanceOf[_address];
    }

    function mint(address _address, uint256 amount) public onlyOwner {
        _balanceOf[_address] += amount;
        totalSupply += amount;

        emit Transfer(msg.sender, _address, amount);
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        if (balanceOf(msg.sender) < _amount) revert InsufficentBalance();

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
        if (balanceOf(_from) < _amount) revert InsufficentBalance();

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

//  ░█▀█░█▀▄░█▀█░█░█░█░█
//  ░█▀▀░█▀▄░█░█░▄▀▄░░█░
//  ░▀░░░▀░▀░▀▀▀░▀░▀░░▀░

contract Proxy {
    address public implementation;
    address public admin;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    function upgrade(address _newImplementation) external {
        require(msg.sender == admin, "not admin");
        implementation = _newImplementation;
    }

    fallback() external payable {
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

/*

    okay after i gave my code the ai responded with this: 

    Your delegatecall explanation is genuinely excellent — the cheating-student analogy is correct and actually a clean way to think about it: the implementation provides the logic ("the answer"), but execution happens in the proxy's own context, so all state changes land in the proxy's storage, not the implementation's. And your explanation of why call breaks it is exactly right — with a regular call, the logic contract would read/write its own storage instead of the proxy's, meaning the proxy would never see any state change at all. That's the correct mental model.

The code is also solid — TokenV2 is now correctly standalone (no inheritance), storage layout matches V1 with owner appended at the end exactly as required, mint() is owner-gated, and the Proxy contract is used as given.

One thing to verify to make sure you actually understand the mechanism, not just copied it correctly — walk through this scenario and tell me what happens:

You deploy TokenV1, deploy Proxy pointing at it, then call Proxy.initialize("MyToken", "MTK", 18, 1000) — through the proxy's fallback, which delegatecalls into V1's initialize().

Then you deploy TokenV2 and call Proxy.upgrade(tokenV2Address).

Question: after the upgrade, if you call Proxy.balanceOf(yourAddress), what number do you get back — and why does it still work correctly even though balanceOf() is now technically "V2's" function code running?



AND HERE IS MY ANSWER: 

well the answer is it uses the proxy storage so the implementations like v1 or v2 or only just logic right so every storage every thing that stays on the proxy that is what the balance and the address are the same becuase they are under the proxy contract storage.


AND THE AI RESPONDED WITH THIS: 


Correct — exactly right.

The balance is still there because it was written to the proxy's storage slot back when initialize() ran through V1's logic. When you later call balanceOf() after upgrading to V2, the proxy delegatecalls into V2's code — but V2's balanceOf() function just does return _balanceOf[_address], and since _balanceOf is storage slot position, not a hardcoded value, it reads whatever is sitting in the proxy's storage at that slot. V1 wrote the data there, V2 reads from the same slot because the layout matches. The logic changed contracts; the data never moved.

That's the entire mechanism, and you've got it correctly in your own words now, not just as copied code.

Tier 4 Exercise 2 — done. ✅


me:
I THINK I GOT THE AI BLESSING TO PASS TO THE NEXT EXERCISE OKAY SO IT IS GOOD EXERCISE I LEARNED NEW THINGS FROM IT AND I KNOW THAT I DIDN'T GOOD THAT MUCH DEEP BUT IF I CAME ACROSS IT I WILL PROBABLY GO DEEP IN IT LIKE IF I EVER NEED TO WRITE AN ARTICLE OR IN JOB OR something, I WILL STUDY AND READ MORE ABOUT IT for now this is enough i believe. 
The more i learn and do the more i know my knowledge is not that much, so i will be working hard and doing what i do best to get more knowledge which fascinate my soul and me being able to contribute in this technology is more exciting to me. I love this industry.

THANK YOU.
*/
