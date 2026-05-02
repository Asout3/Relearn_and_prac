// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*
The Whitelist Contract
Write a contract called Whitelist that does the following:

Owner can add an address to the whitelist
Owner can remove an address from the whitelist
Anyone can check if an address is whitelisted
Only whitelisted addresses can call a function called doSomething() — it doesn't need to do anything real, just revert if caller isn't whitelisted
Owner can check how many addresses are currently whitelisted

Requirements:

Use a mapping to track whitelist
Use a counter for total whitelisted count
Custom error if non-whitelisted calls doSomething()
Emit an event when address is added and when removed
*/

/*
okay i understand this shit lets start i know like i got some naming and spelling issue but ya lets stick to the logic okay lets goooo
i can use array for the wait list
they can put the address and like from that list 
you can check if you are in
okay i understad it it is besically a loop
okay i undersatnd.

lets start.

*/

error AlreadyRegistered();
error NotRegistered();

contract Whitelist {
    event WhitelistAdded(address _address);
    event WhitelistRemoved(address _address);
    event DidSomthing();


    address public owner;
    address[] whitelisted;
    uint256 public whitelistedAmount;
    uint256 public count;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) public index;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not owner");
        _;
    }

    function addAddress(address _address) public onlyOwner {
        if(whitelist[_address]) revert AlreadyRegistered();

        whitelist[_address] = true;
        index[_address] = whitelisted.length;
        
        whitelisted.push(_address);
        whitelistedAmount++;

        emit WhitelistAdded(_address);
    }

    function removeAddress(address _address) public onlyOwner {
        if(!whitelist[_address]) revert NotRegistered();

        // okay this is kinda complicated it is besically datastructre and algorithm which says like delete the shit that you want from the array so we could use a lot of option since this is like only practice so i don't really go deep and like consider the gas optimization okay.
        // so i will try to explain this part okay let start 
        // what i want is like to accept the address that i want to delete and delete it how i am going to do it is like
        // first check if that address exist if not registered i will revert
        // i actually asked chatgpt how to do this shit like to put a value to the end so i can remove it but its good know.


        // get the index place of the address it could be like any where like 2 or 3 or what ever
        uint i = index[_address];
        // get the last user index value like what the code does is like it gets the last user address how?
        // from the whitelisted array it find the last array and then assign its value to lastUser.
        address lastUser = whitelisted[whitelisted.length - 1];
        // so now we have the index of the about to remove address
        // and also we have the address of the last user

        // we change the value of address i which is the address which is about to be removed so we have two similar value in the array.
        whitelisted[i] = lastUser;
        // then we swap it cuz we find the index last user then we update its index to i which is i is the address which is about to be removed
        index[lastUser] = i;

        // removed it the address from the array cus it is last now
        whitelisted.pop();

        // then delte them from the mapping.
        delete whitelist[_address];
        delete index[_address];
        whitelistedAmount--;

        emit WhitelistRemoved(_address);
    }

    function checkIfWhitelisted(address _address) public view returns (string memory) {
        if(whitelist[_address]){
            return "you in bruv";
        } else {
            return "nah u no in it";
        }
    }

    function doSomething() public {
        if(!whitelist[msg.sender]) revert NotRegistered();
        count++;
        emit DidSomthing();
    }

    function viewHowManyWhitelisted() public view returns (uint256) {
        return whitelistedAmount; // i don't know if this is the optimzed way but like i coudl also use the array length but like it is ordered so i used counter okay
    }
}