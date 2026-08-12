// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 *                               $$\   $$\
 *                               $$ |  $$ |
 * $$\    $$\ $$$$$$\  $$\   $$\ $$ |$$$$$$\
 * \$$\  $$  |\____$$\ $$ |  $$ |$$ |\_$$  _|
 *  \$$\$$  / $$$$$$$ |$$ |  $$ |$$ |  $$ |
 *   \$$$  / $$  __$$ |$$ |  $$ |$$ |  $$ |$$\
 *    \$  /  \$$$$$$$ |\$$$$$$  |$$ |  \$$$$  |
 *     \_/    \_______| \______/ \__|   \____/
 *
 *
 *
 */

/**
 * Write a contract called Vault that accepts a single ERC20 token and:
 *
 * Anyone can deposit tokens and receive shares back
 * Anyone can withdraw by burning their shares and getting tokens back
 * Shares represent proportional ownership — early depositors get more shares per token
 * Anyone can check the total assets held by the vault
 * Anyone can check how many shares an address holds
 * Anyone can preview how many shares a deposit would give without executing
 *
 * The share math works like this:
 * solidity// First deposit — shares = amount (1:1)
 * // After that:
 * totalShares) / totalAssets
 *
 * // Withdrawal:
 * totalAssets) / totalShares
 *
 * Requirements:
 *
 * Use an existing ERC20 as the underlying token — write a simple MockToken alongside it
 * deposit(uint256 assets) → pulls tokens from user, mints shares
 * withdraw(uint256 shares) → burns shares, sends tokens back
 * previewDeposit(uint256 assets) → returns shares without state change
 * Custom errors for zero amount and insufficient shares --- 000
 * Emit events for deposit and withdrawal
 */

interface IAsout3Token {
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _address) external view returns (uint256);
}

error InsufficentAllowance();
error InsufficentBalance();

contract ShareToken {
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
 * okay this complicated but i can do it i am kinda realy tired but okay let me plan at first so it says we need to like
 * create mock erc20 contract so like i got that like no worries  so lets talk about the function let me write them up before writing them up
 * deposite(uint256 assets) - this this is not like just some recording so it uses pull method so how is that so the deposite uses like transfer from ya that is it understood it uses transfer from it calles it.
 * withdraw(uint256 share) - it is just simple just burn share and calculate the shit and give what i owes.
 * previewDeposit(uint256 assets) - this show how much share he has like only view function.
 * Anyone can check the total assets held by the vault - i think we just do some getter and do it right.
 * Anyone can check how many shares an address holds.
 * Anyone can preview how many shares a deposit would give without executing.
 *
 * nah it is still complicated a little bit but the note clered it up so like it would help so like on the next session i will be like breaking it down and continue working on it okay
 *
 * okay i asked it it is giving me some information so the first thing is like we need to accept the token from the user and we need to deposite the token
 * so i pull the interface of the token okay so let me show you that.
 *
 *
 *
 *
 *
 */

error ZeroAmountInputed();
error InsufficentShare();

contract Vault {
    event Deposite(address indexed _address, uint256 indexed _amount);
    event Withdraw(address indexed _address, uint256 indexed _amount);

    IAsout3Token public token;
    ShareToken public shareToken;

    constructor(address _token) {
        token = IAsout3Token(_token);
        shareToken = new ShareToken("Vault Share", "VSHARE", 18, 0);
    }

    function deposite(uint256 _amount) external {
        if (_amount == 0) revert ZeroAmountInputed();
        // this is the share variable which i used to store the share to calculate
        uint256 share;

        // this is me calculating the amount of share if the valut is zero share is _amount other wise i put it in the
        // formula that i get from asking google but the formula works best it is standard.
        /// NOTICE: THIS contract has a bug which is like in erc4626 type of contract there is a bug called the inflation attack let me explain:
        // so the bug is besically the attacker waits till new valut is opend or created with very little or no money in it so they put a little money in it and they get like 1 : 1
        // then they donate a lot of money like 100k or somthing like that they didn't put like deposite they just send it ot the contract they just donted it so like they don't get share back
        // so this is the magic the got like 100,001 in the contract and like when other user came and deposite the calculation is like they get very little amount of share the decimal soldity won't really count it and round it to zero.
        // so if someone deposite 100 dollar they get like besically 0 share and the attacker withdraw all the money 100,101 money so the attacker profit the money.
        // so openzeppline kinda have a way which is like creating virtual share and virtula money in the vault like it kinda hurts the attcker like like if he deposite 100k he would get only half back so like those kinds of attack could happen
        // since this is only practice contract i will not do or implement any kind of openzeppline or virtualshare or virtuallasset i am gonna make it raw okay.
        if (shareToken.totalSupplies() == 0) {
            share = _amount;
        } else {
            share = (_amount * shareToken.totalSupplies()) / token.balanceOf(address(this));
        }

        // this is me trying to pull the money from the user
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "transaction failed");

        // minting the share and giving to the user.
        shareToken.mint(share, msg.sender);
        emit Deposite(msg.sender, _amount);
    }

    function withdraw(uint256 _sharesToBurn) external {
        if (shareToken.balanceOf(msg.sender) < _sharesToBurn) revert InsufficentShare();
        if (_sharesToBurn == 0) revert ZeroAmountInputed();
        // calculate tokens to give back: amount = (shares * totalAssets) / totalShares
        uint256 amount;

        amount = (_sharesToBurn * token.balanceOf(address(this))) / shareToken.totalSupplies();

        // burn shares
        shareToken.burn(msg.sender, _sharesToBurn);

        // send tokens to user
        bool success = token.transfer(msg.sender, amount);
        require(success, "transactoin failed");

        emit Withdraw(msg.sender, amount);
    }

    function previewDeposit(uint256 _amount) external view returns (uint256) {
        uint256 share;

        if (shareToken.totalSupplies() == 0) {
            return _amount;
        } else {
            share = (_amount * shareToken.totalSupplies()) / token.balanceOf(address(this));
            return share;
        }
    }

    //Anyone can check the total assets held by the vault
    function totalAsset() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    //Anyone can check how many shares an address holds
    function sharesOf(address _address) external view returns (uint256) {
        return shareToken.balanceOf(_address);
    }
}

