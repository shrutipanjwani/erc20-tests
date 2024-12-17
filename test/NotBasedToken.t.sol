// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/NotBasedToken.sol";
import "../src/NotBasedToken.sol";

contract NotBasedRewarderTest is Test {
    NotBasedToken public rewardToken;
    NotBasedToken public depositToken;
    NotBasedRewarder public rewarder;
    address public owner;
    address public alice;

    function setUp() public {
        owner = address(this);
        alice = address(0x1);
        
        // Deploy tokens
        rewardToken = new NotBasedToken(address(this));
        depositToken = new NotBasedToken(address(this));
        
        // Deploy rewarder
        rewarder = new NotBasedRewarder(IERC20(address(rewardToken)), IERC20(address(depositToken)));
        
        // Give Alice some deposit tokens
        depositToken.transfer(alice, 1000e18);
    }

    function testFailWithdrawPausedToken() public {
        // Alice deposits
        vm.startPrank(alice);
        depositToken.approve(address(rewarder), 100e18);
        rewarder.deposit(100e18);
        
        // Wait 24 hours
        skip(24 hours + 1);
        
        // Owner pauses the reward token
        vm.stopPrank();
        rewardToken.pause();
        
        // Alice tries to withdraw - will fail because reward token is paused
        vm.prank(alice);
        rewarder.withdraw(100e18);
    }

    function testFailWithdrawZeroBalance() public {
        // Alice deposits
        vm.startPrank(alice);
        depositToken.approve(address(rewarder), 100e18);
        rewarder.deposit(100e18);
        
        // Wait 24 hours
        skip(24 hours + 1);
        
        // Rewarder has no reward tokens
        vm.prank(alice);
        rewarder.withdraw(100e18);
    }

    function testRewardExploit() public {
        // Alice deposits
        vm.startPrank(alice);
        depositToken.approve(address(rewarder), 1000e18);
        
        // Multiple small deposits instead of one large deposit
        for(uint i = 0; i < 10; i++) {
            rewarder.deposit(10e18);
        }
        
         vm.stopPrank();
    }
}