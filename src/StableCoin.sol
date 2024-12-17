// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StableCoin is ERC20Burnable, Ownable(msg.sender) {

    constructor() ERC20("MyBurnableToken", "MBT") {
        
    }
    
    mapping(address account => bool) public isFrozen;

    function mint(address receiver, uint256 amount) public onlyOwner {
        _mint(receiver, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }

    function freeze(address account) public onlyOwner {
        isFrozen[account] = true;
    }

    function unfreeze(address account) public onlyOwner {
        isFrozen[account] = false;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(!isFrozen[msg.sender], "account frozen");
        return super.transfer(to, amount);
    }
    
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(!isFrozen[msg.sender], "account frozen");
        return super.transferFrom(from, to, amount);
    }
}