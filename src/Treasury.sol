// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*
 Multi-Role Treasury Contract
Write a contract called Treasury that:

Holds ETH
Has 3 roles: Admin, Manager, Viewer
Admin can add and remove managers
Admin can withdraw any amount
Manager can withdraw up to 0.5 ETH at a time
Viewer can only view the balance
Anyone can deposit ETH into the treasury
Admin is set in the constructor

Requirements:

Use a mapping to track roles per address
Use an enum for the roles
Custom errors for unauthorized access and exceeding withdrawal limit
Emit events for deposits, withdrawals, and role changes

*/

/*
okay lets start this is kinda new topic for me honestly but like i will try to like make it happen this is like connect the dots tyepshit but i will try i don't thing asking google or any kind of ai is like important for this thing so ya lets do it we got this.


//  AFTER LUNCH TODO
    - REFACOTR THE ROLES USING THIS -> Use a mapping to track roles per address = DONE
    - SET UP EVENTS. = DONE


    QUESTIONS ON MY MIND
    - HOW DO I KNOW IF A WAY OR METHOD THAT I THINK IS THE BEST THERE IS A LOT DIFFERENT WAY BUT HOW DO I COME UP WITH THE BEST ONE?
*/
// let me explain the code

// custom errors 
error ManagerDoesNotExist();
error ManagerExist();
error YouCanNotWithDrawThisAtOneTime();
error NotAuthorized();

// the contract 
contract Treasury {

    // events 
    event Deposited(address indexed _address, uint256 indexed amount);
    event Withdrawal(address indexed _role, uint256 indexed amount);
    event RoleChanged(address indexed _removed, address indexed _added);

    // state variables
    address public admin;
    //uint256 public vault; // this is the vault where the money is stored
    uint256 public withdrawAmountForManager = 0.5 ether; // this is kinda where i store like the limitaion for ground manager withdrawal
    mapping(address => roles) public assignedRoles; // this is the mapping for the address and role relation address to the role they have

    // the enum roles
    enum roles {  
        admin,
        manager,
        viewer
    }
    

    // this is the constructor which i set the admin here
    constructor() {
        admin = msg.sender;
        assignedRoles[msg.sender] = roles.admin; // or we can do this like input an address like but for exercise sake we did this okay.
    }

    // modifers
    modifier onlyAdmin() {
        require(assignedRoles[msg.sender] == roles.admin, "you are not Admin");
        _;
    }

    // modifers
    modifier onlyManager() {
        require(assignedRoles[msg.sender] == roles.manager, "you are not manager");
        _;
    }

    // this is addmanager function only admin can access it 
    function addManager(address _address) public onlyAdmin {
        if(assignedRoles[_address] == roles.manager) revert ManagerExist();

        assignedRoles[_address] = roles.manager;
        emit RoleChanged(address(0), _address);
    }

    // this is remove manager function 
    function removeManager(address _address) public onlyAdmin {
        if(assignedRoles[_address] != roles.manager) revert ManagerDoesNotExist();

        assignedRoles[_address] = roles.viewer;
        emit RoleChanged(_address, address(0));
    }

    // this is incase
     receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // deposite func
    function deposit() public payable {
        emit Deposited(msg.sender, msg.value);
    }

    // withdrawal func
    function withdraw(uint256 amount) public {
    if(assignedRoles[msg.sender] != roles.admin && 
       assignedRoles[msg.sender] != roles.manager) revert NotAuthorized();
    if(assignedRoles[msg.sender] == roles.manager && 
       amount > withdrawAmountForManager) revert YouCanNotWithDrawThisAtOneTime();

    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
    emit Withdrawal(msg.sender, amount);
    }

    function viewVault() public view returns(uint256) {
        return address(this).balance;
    }

    // the reason i didn't put view function for the vault variable cuz its public so solidity will create getter automatically so ya


}