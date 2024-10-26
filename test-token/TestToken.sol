// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TestToken is ERC20, ERC20Permit {
    constructor() ERC20("TestToken", "TESTERC20") ERC20Permit("TestToken") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); 
    }

    function airdrop() public {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}