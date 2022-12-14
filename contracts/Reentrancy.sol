// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";

contract Reentrance {
    // No overflows
    using SafeMath for uint256;

    // Mapping of address to balances
    mapping(address => uint) public balances;

    function donate(address _to) public payable {
        // Donate  is used to increase the balance of our relevant addr in the contract
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint balance) {
        return balances[_who];
    }

    function withdraw(uint _amount) public {
        // First check that we are withdrawing a valid amount
        if (balances[msg.sender] >= _amount) {
            // we use call to withdraw
            (bool result, ) = msg.sender.call{value: _amount}("");
            if (result) {
                //
                _amount;
            }
            // ? : Is there a way here for us to prevent this from registering
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}
