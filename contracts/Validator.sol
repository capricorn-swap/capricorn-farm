// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./interfaces/IValidator.sol";
import "./libraries/CapswapV2Library.sol";
import "./MasterChef.sol";

contract Validator is IValidator{

	address public masterChef;
	address public swapFactory;
	address public valueToken;

	uint256 public threshold=500*10**18;

	constructor(address _masterChef, address _swapFactory,address _valueToken){
		masterChef = _masterChef;
		swapFactory = _swapFactory;
		valueToken = _valueToken;
	}

	function qualified(address user) override external view returns (bool){
		(uint user_amount,) =MasterChef(masterChef).userInfo(0,user);

		address corn = address(MasterChef(masterChef).corn());

		(uint reserveA, uint reserveB) = CapswapV2Library.getReserves(swapFactory,corn,valueToken);
		uint user_value = CapswapV2Library.quote(user_amount,reserveA,reserveB);

		return user_value > threshold;
	}
	function info() override external pure returns (string memory){
		return "corn staking value must bigger than 500$";
	}
}