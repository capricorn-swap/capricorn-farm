// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IIFOPool.sol";

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
		uint userCount;
	}

	function poolsLength() external  view returns(uint256);

	function validator() external view returns (address);
	function WCUBE() external view returns (address);

	function swapRouter() external view returns (address);
	function swapFactory() external view returns (address);

	function feeTo() external view returns (address);

	function excessRate() external view returns(uint256); // x/100

	function openfeeToken() external view returns(address);
	function openfeeAmount() external view returns(uint256);
	function ifoFeeRate() external view returns (uint256); // x/10000

	function mySeeds(address user) external view returns(PoolInfo [] memory _pools);
	function myCrops(address user) external view returns(PoolInfo [] memory _pools);
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

	function enter(uint256 pid,address user) external;
	function quit(uint256 pid,address user) external;
}
