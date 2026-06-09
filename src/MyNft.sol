// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*
ERC721 From Scratch
Write a contract called MyNFT that:

Has a name and symbol
Owner can mint an NFT to any address
Each NFT has a tokenId that auto-increments from 1
Anyone can check who owns a specific tokenId
Anyone can check how many NFTs an address owns
Owner of an NFT can transfer it to another address
Owner of NFT can approve another address to transfer a specific tokenId
Anyone can check who is approved for a specific tokenId

Requirements:

mapping(uint256 => address) for token ownership
mapping(address => uint256) for balance per address
mapping(uint256 => address) for token approvals
Custom errors for not owner, not approved, nonexistent token
Emit Transfer and Approval events

*/

/*
okay lets start right i don't want to talk alot about it but i got this i know i got this and i will solve it every time i do this problem i got better my skill got better so what i know about this is i got this i will try to explain the what i did after i finish okay.
*/

// let me explain the code okay let start 

// this are the custom errors as u can see.
error cantSendToZeroAddress();
error youAreNotOwner();
error youDoNotOwnTheToken();

// the nft contract i know we can use like openzeppline things but like since we are learning i need to learn to do thing by my self okay
// so lets start with the erc721 so i don't really know like they said it have some function same as the erc20 but like in this contract i didn't put any kind of like image and something like that cuz more time to like learn about it and didn't really get asked okay.
contract MyNft {

    // events as u can see and u can understand from the name of the even okay
    event OwnershipTrasfered(address indexed _from, address indexed _to, uint256 indexed _id);
    event Transfered(address indexed _from, address indexed _to, uint256 indexed _id);
    event Approved(address indexed _owner, address _spender, uint256 indexed _id);

    // variables 
    address public owner;
    string public name;
    string public symbol;
    uint256 public id = 1;

    // my mappings 
    mapping(uint256 => address) public nftOwner;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public listOfApprovals;

    // constructor to set things up it works well as u can see
    constructor(string memory _name, string memory _symbol) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
    }

    // this is like the only owner modier as u know it filter the owner of the contract
    modifier onlyOwner() {
        require(owner == msg.sender, "you are not the owner");
        _;
    }

    // this is mint function we are asked to put it and the owner like only the owner can mint a new nft and can sent it to anyone he want;
    function mint(address to) public onlyOwner() {
        // i don't know why i put this zero address thing but like in real life the probablity of the owner sending to zero address is like very low but i put it any way.
        if(to == address(0)) revert cantSendToZeroAddress();
        // my actions
        nftOwner[id] = to;
        balanceOf[to] += 1;
        emit OwnershipTrasfered(address(0), to, id); 
        id++;
        
    }

    // this function checks the owner of an nft by puting its id and it returns the address of that token owner
    function ownerOf(uint256 _id) public view returns (address) {
        return nftOwner[_id];
    }

    // this function trys to list out the amount of nft that address have how much it have it calls the balanceOf variable.
    // this function might be redundent but like i don't know i want to keep it okay
    function amountOfNft(address _owner) public view returns (uint256) {
        return balanceOf[_owner];
    }

    // this function transfer ownershit of its nft it gives ownership of its nft 
    function transferOwnership(address _from, address _to, uint256 _id) public {
        // i don't know this might not be it but like i think it is a cool way to check an ownership
        if(_from != msg.sender) revert youAreNotOwner(); 
        // lets try to check if its a really true owner
        if(nftOwner[_id] != _from) revert youDoNotOwnTheToken();
        
        // actions
        // i assign the new owner
        nftOwner[_id] = _to;
        // deduct from the previous owner
        balanceOf[_from] -= 1;
        // increment to the reciver 
        balanceOf[_to] += 1;

        // emit my event
        emit OwnershipTrasfered(_from, _to, _id);
    }

    // this function gives approval to the addresses
    function approve(address _to, uint256 _id) public {
        //first lets check if the msg.sender is the owner of that id
        if(nftOwner[_id] != msg.sender) revert youDoNotOwnTheToken();
    
        // this is the list of the approved like approved id with like addresses
        listOfApprovals[_id] = _to;
        
        emit Approved(msg.sender, _to, _id);
    }

    // check for approved addresses
    function approvedAddresses(uint256 _id) public view returns(address) {
        return listOfApprovals[_id];
    }

    // i don't really remeber we got asked for this function but i added it any way
    function transfer(address _to, uint256 _id) public {
        if(nftOwner[_id] != msg.sender) revert youDoNotOwnTheToken();
        if(_to == address(0)) revert cantSendToZeroAddress();

        // my acctions
        nftOwner[_id] = _to;
        balanceOf[msg.sender] -= 1;
        balanceOf[_to] += 1;

        emit Transfered(msg.sender, _to, _id);
    }

    // this transfer from function
    // same as before
    function transferFrom(address _from, address _to, uint256 _id) public {
        if(nftOwner[_id] != _from) revert youDoNotOwnTheToken();
        if( approvedAddresses(_id) != msg.sender) revert youAreNotOwner();
        if(_to == address(0)) revert cantSendToZeroAddress();

        nftOwner[_id] = _to;
        balanceOf[_from] -= 1;
        balanceOf[_to] += 1;

        emit Transfered(_from , _to, _id);
    }

    // i wrote thsi thing by my self it might be like got some bugs but this is what i think.

    /*  this are the naming issues like that needs to be correct but i didn't cuz i want to keeps its originality idk

        mine                   Fix
        cantSendToZeroAddress - ZeroAddress
        youAreNotOwner - NotOwner
        youDoNotOwnTheToken - NotTokenOwner
        OwnershipTrasfered - Transfer — this is the standard name
        Transfered - Transfer — same event, one typoMyNftMyNFT

    */

}
