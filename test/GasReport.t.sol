// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {RewardVault} from "../src/GasOptimization.sol";

// 1. We create a fake ERC20 token so deposit/withdraw can run properly
contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

// 2. This is the actual test contract
contract RewardVaultTest is Test {
    RewardVault public vault;
    MockERC20 public token;

    address public owner = address(this); // The test contract acts as the owner
    address public user = address(0x123); // A fake user address

    function setUp() public {
        // Deploy our fake token and the vault
        token = new MockERC20();
        vault = new RewardVault(address(token));

        // Give the user 1000 tokens and approve the vault to spend them
        token.mint(user, 1000e18);
        
        // Prank as the user to approve the tokens
        vm.prank(user);
        token.approve(address(vault), type(uint256).max);
    }

    // Tests the gas for depositing
    function testDeposit() public {
        vm.prank(user); // Pretend to be the user
        vault.deposit(100e18);
    }

    // Tests the gas for withdrawing
    function testWithdraw() public {
        // User must deposit first before withdrawing
        vm.startPrank(user);
        vault.deposit(100e18);
        vault.withdraw(50e18);
        vm.stopPrank();
    }

    // Tests the gas for setting a fee (only owner)
    function testSetFee() public {
        vault.setFee(10);
    }

    // Tests the gas for pausing the contract (only owner)
    function testPause() public {
        vault.pause();
    }

    // Tests the gas for reading user summary
    function testGetUserSummary() public view {
        vault.getUserSummary(user);
    }

    // Tests the gas for batch checking active users
    function testBatchCheckActive() public view {
        // Create an array of 3 users to check
        address[] memory users = new address[](3);
        users[0] = address(0x1);
        users[1] = address(0x2);
        users[2] = address(0x3);
        
        vault.batchCheckActive(users);
    }
}