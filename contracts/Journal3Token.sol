
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./errors.sol";

contract Journal3Token is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // mint 10 Million tokens for owner
        _mint(msg.sender, 10000000 * (10 ** 18));
    }

    mapping(address => uint) public lockTime;

    function requestTokens (address requestor , uint amount) external {
        
        if(block.timestamp <= lockTime[msg.sender])
           revert LockTimeExceeded();

        transfer(requestor, amount);

        //updates locktime 5 minutes from now
        lockTime[msg.sender] = block.timestamp + 5 minutes;
    }
}
