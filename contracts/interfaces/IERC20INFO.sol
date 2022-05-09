// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface IERC20INFO is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
