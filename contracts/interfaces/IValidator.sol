// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IValidator{
	function qualified(address user) external view returns (bool);

	function info() external view returns (string memory);

	function vote(address user) external view returns (uint user_value);
}