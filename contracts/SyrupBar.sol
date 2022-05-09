// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./CapricornToken.sol";

// SyrupBar with Governance.
contract SyrupBar is Ownable{
    using SafeMath for uint256;

    // The CAPRICORN TOKEN!
    CapricornToken public cpct;

    constructor(
        CapricornToken _cpct
    ) {
        cpct = _cpct;
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCapricornTransfer(address _to, uint256 _amount) public onlyOwner {
        uint256 capricornBal = cpct.balanceOf(address(this));
        if (_amount > capricornBal) {
            cpct.transfer(_to, capricornBal);
        } else {
            cpct.transfer(_to, _amount);
        }
    }

}
