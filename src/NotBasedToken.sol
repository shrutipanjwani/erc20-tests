// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NotBasedToken is ERC20Pausable, Ownable {
		constructor(address rewarder) ERC20("NBToken", "NBT") Ownable(msg.sender) {
			_mint(rewarder, 100_000_000e18);
		}
		
		function pause() external onlyOwner {
				_pause();
		}
		
		function unpause() external onlyOwner {
				_unpause();
		}
}

contract NotBasedRewarder {
		IERC20 rewardToken;
		IERC20 depositToken;
		
		constructor(IERC20 _rewardToken, IERC20 _depositToken) {
				rewardToken = _rewardToken;
				depositToken = _depositToken;
		}
		
		mapping(address => uint256) internalBalances;
		mapping(address => uint256) depositTime; 
		
		function deposit(uint256 amount) public {
				require(rewardToken.allowance(msg.sender, address(this)) > amount, "insufficient allowance");
				
				depositToken.transferFrom(msg.sender, address(this), amount);
				internalBalances[msg.sender] += amount;
				depositTime[msg.sender] = block.timestamp;
		}
		
		// give a bonus if they staked for more than 24 hours
		function withdraw(uint256 amount) external {
				require(amount < internalBalances[msg.sender], "insufficient balance");
				if (block.timestamp > depositTime[msg.sender] + 24 hours) {
						rewardToken.transfer(msg.sender, amount);
				}
				
				// give back their tokens
				depositToken.transfer(msg.sender, amount);
		}				
}