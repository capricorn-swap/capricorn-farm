// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIFOFactory {

	struct PoolInfo{
		address pool_address;
		address initiator;
		bool verified;
		address sellToken;
		uint sellAmount;
		address raiseToken;
		uint raiseAmount;
		uint startTimestamp;
		uint endTimestamp;
		stakePeriod period;
		string metaData; // json string {"siteURL": "http://xxx","reportURL": "http://xxx"}
	}
	enum stakePeriod {
		ONE_MONTH,
		TWO_MONTH,
		THREE_MONTH
	}

	function poolsLength() external  view returns(uint256);
	function pools(uint256 pid) external view returns(PoolInfo memory poolInfo);
	function excessRate() external view returns(uint256); // x/100

	function openfeeToken() external view returns(address);
	function openfeeAmount() external view returns(uint256);
	function ifoFeeRate() external view returns (uint256); // x/10000

	function mySeeds(address user) external view returns(PoolInfo [] memory _pools);
	function verifiedPools() external view returns(PoolInfo [] memory _pools);

	function verify(uint256 pid,bool verified) external;

	function createPool(
		address sellToken,
		uint sellAmount,
		address raiseToken, 
		uint raiseAmount,
		uint startTimestamp,
		uint endTimestamp,
		stakePeriod period,
		string memory metaData // json string 
		) external returns(address pool);
}
