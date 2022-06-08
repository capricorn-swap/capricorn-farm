// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIFOPool {

	enum stakePeriod {
		ONE_MONTH,
		TOW_MONTH,
		THREE_MONTH
	}


	function init(
		address _initiator,
		address _sellToken,
		uint _sellAmount,
		address _raiseToken, 
		uint _raiseAmount,
		uint _startTimestamp,
		uint _endTimestamp,
		stakePeriod _period,
		string memory _metaData // json string 
	) external;

	function poolInfo() external view returns (
		bool _verified,
		address _initiator,
		address _sellToken,
		uint _sellAmount,
		address _raiseToken, 
		uint _raiseAmount,
		uint _startTimestamp,
		uint _endTimestamp,
		stakePeriod _period,
		string memory _metaData, // json string 
		uint256 _userCount
	);

	function verify(bool _verified) external;

	function deposit(uint256 amount) external;
	function quit(uint256 amount) external;
	function claim() external;

	function pending(address user) external view returns (uint256 amount);

}
