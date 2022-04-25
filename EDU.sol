// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Bounty.sol"

contract EDU is ERC20, Ownable {
    constructor(uint256 0) ERC20("EDU", "EDU") {
    }
    Bounty b;
    transferOwnership(b.getAddress());
}
