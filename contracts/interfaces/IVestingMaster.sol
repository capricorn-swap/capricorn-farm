// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVestingMaster {
    struct LockedReward {
        uint256 locked;
        uint256 timestamp;
    }

    event Lock(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    function lock(address, uint256) external returns (bool);
    function claim() external returns (bool);
    function period() external view returns (uint256);
    function lockedPeriodAmount() external view returns (uint256);
    function vestingToken() external view returns (IERC20);
    /*
    function userLockedRewards(address account, uint256 idx)
        external
        view
        returns (uint256, uint256);
    */
    function totalLockedRewards() external view returns (uint256);
    function getVestingAmount(address account) external view returns (uint256, uint256);
}
