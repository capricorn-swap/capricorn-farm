// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

import "./interfaces/IWCUBE.sol";
import "./interfaces/IIFOFactory.sol";
import "./interfaces/ICapswapV2Router02.sol";
import "./IFOPool.sol";

contract IFOFactory is IIFOFactory,Ownable{

	using EnumerableSet for EnumerableSet.UintSet;
	using SafeMath for uint256;

	uint256 public MIN_TIME = 600;
	uint256 public MAX_TIME = 3600*24*14;
	uint256 public MIN_PERIOD = 0;
	address public override WCUBE;
	address public override validator;

	address public override swapRouter;
	address public override swapFactory;

	address public override feeTo;

	PoolInfo [] public pools;
	uint256 public override excessRate=20; // x/100
	address public override openfeeToken;
	uint256 public override openfeeAmount;
	uint256 public override ifoFeeRate=30; // x/10000

	mapping(address => EnumerableSet.UintSet) seeds;
	mapping(address => EnumerableSet.UintSet) crops;
	EnumerableSet.UintSet verified;
	uint256 public override slippage=3;

	event CreatePoolEvent(address sellToken,
		uint sellAmount,
		address raiseToken, 
		uint raiseAmount,
		uint startTimestamp,
		uint endTimestamp,
		uint period,
		string metaData);

	//event NewValidatorEvent(address validator);
	//event NewFeeToEvent(address feeTo);
	//event NewExcessRate(uint256 rate);
	//event NewOpenfeeToken(address token);
	//event NewOpenfeeAmount(uint256 amount);
	//event NewFeeRate(uint256 rate);
	//event Verify(uint256 pid, address pool, bool verified);
	event Enter(uint256 pid, address pool, address user);
	event Quit(uint256 pid, address pool, address user);

	constructor(address _wcube, address _swapRouter,address _validator) {
        WCUBE = _wcube;
        swapRouter = _swapRouter;
        swapFactory = ICapswapV2Router02(swapRouter).factory();
        validator = _validator;
    }

    function createPool(
		address sellToken,
		uint sellAmount,
		address raiseToken, 
		uint raiseAmount,
		uint startTimestamp,
		uint endTimestamp,
		uint period,
		string memory metaData // json string 
		) override external returns(address pool){

		require(sellToken != raiseToken,'same token');
        if(startTimestamp < block.timestamp){
            startTimestamp = block.timestamp;
        }
        require(endTimestamp.sub(startTimestamp) > MIN_TIME,'time too short');
        require(endTimestamp.sub(startTimestamp) < MAX_TIME,'time too long');
        require(period >= MIN_PERIOD,'too short period');

		{
			bytes memory bytecode = type(IFOPool).creationCode;
	        bytes32 salt = keccak256(abi.encodePacked(sellToken, raiseToken, startTimestamp, endTimestamp));
	        assembly {
	            pool := create2(0, add(bytecode, 32), mload(bytecode), salt)
	        }
        }

        // transfer sellToken and openfeeToken
        IERC20(sellToken).transferFrom(msg.sender,pool,sellAmount.mul(200+excessRate).div(100));
        IERC20(openfeeToken).transferFrom(msg.sender,pool,openfeeAmount);

		uint256 pid = pools.length;
		IIFOPool(pool).init(
			pid,
			msg.sender,
			sellToken,
			sellAmount,
			raiseToken,
			raiseAmount,
			startTimestamp,
			endTimestamp,
			period,
			metaData
		);
		pools.push(PoolInfo({
			pool_address:pool,
			initiator:msg.sender,
			verified:false,
			sellToken:sellToken,
			sellAmount:sellAmount,
			raiseToken:raiseToken,
			raiseAmount:raiseAmount,
			startTimestamp:startTimestamp,
			endTimestamp:endTimestamp,
			period:period,
			metaData:metaData,
			userCount:0
		}));

		seeds[msg.sender].add(pid);

		emit CreatePoolEvent(sellToken,
			sellAmount,
			raiseToken, 
			raiseAmount,
			startTimestamp,
			endTimestamp,
			period,
			metaData);
			
	}

    function poolsLength() override external  view returns(uint256){
    	return pools.length;
    }

    function setSlippage(uint256 _slippage) external onlyOwner{
    	require(_slippage < 100,'too large slippage');
    	slippage = _slippage;
    }

    function setValidator(address _validator) external onlyOwner{
		validator = _validator;
		//emit NewValidatorEvent(validator);
	}

	function setMinTime(uint256 min_time) external onlyOwner{
    	MIN_TIME = min_time;
    }

    function setMaxTime(uint256 max_time) external onlyOwner{
    	MAX_TIME = max_time;
    }

    function setMinPeriod(uint256 min_period) external onlyOwner{
    	MIN_PERIOD = min_period;
    }

	function setFeeTo(address _feeTo) external onlyOwner{
		feeTo = _feeTo;
		//emit NewFeeToEvent(feeTo);
	}

	function setExcessRate(uint256 _rate) external  onlyOwner{ // x/100
		excessRate = _rate;
		//emit NewExcessRate(excessRate);
	}

	function setOpenfeeToken(address _token) external onlyOwner{
		openfeeToken = _token;
		//emit NewOpenfeeToken(openfeeToken);
	}

	function setOpenfeeAmount(uint256 _amount) external onlyOwner{
		openfeeAmount = _amount;
		//emit NewOpenfeeAmount(openfeeAmount);

	}
	function setIfoFeeRate(uint256 _rate) external onlyOwner{ // x/10000
		ifoFeeRate = _rate;
		//emit NewFeeRate(ifoFeeRate);
	}

	function mySeeds(address user) override external view returns(PoolInfo [] memory _pools){
		uint256 my_seends_length = seeds[user].length();
		_pools = new PoolInfo[](my_seends_length);
		for(uint i = 0; i < my_seends_length;i++){
			uint256 pid = seeds[user].at(i);
			_pools[i]=pools[pid];
		}
	}

	function myCrops(address user) override external view returns(PoolInfo [] memory _pools){
		uint256 my_cropss_length = crops[user].length();
		_pools = new PoolInfo[](my_cropss_length);
		for(uint i = 0; i < my_cropss_length;i++){
			uint256 pid = crops[user].at(i);
			_pools[i]=pools[pid];
		}
	}

	function verifiedLength() external view returns(uint length){
		length = verified.length();
	}

	function verifiedPool(uint index) external view returns(PoolInfo memory _pool){
		return pools[verified.at(index)];
	}

	function verifiedPools() override external view returns(PoolInfo [] memory _pools){
		uint256 verified_length = verified.length();
		_pools = new PoolInfo[](verified_length);
		for(uint i = 0; i < verified_length;i++){
			uint256 pid = verified.at(i);
			_pools[i]=pools[pid];
		}
	}

	function verify(uint256 pid,bool _verified) override external onlyOwner{
		address pool = pools[pid].pool_address;
		IIFOPool(pool).verify(_verified);
		if(_verified){
			verified.add(pid);
		}
		else{
			verified.remove(pid);
		}
		//emit Verify(pid,pool,_verified);
	}

	function enter(uint256 pid,address user) override external{
		require(pools[pid].pool_address == msg.sender,'invalid address');
		bool new_user = crops[user].add(pid);
		if(new_user){
			pools[pid].userCount += 1;
		}
		
		emit Enter(pid,msg.sender,user);
	}
	function quit(uint256 pid,address user) override external{
		require(pools[pid].pool_address == msg.sender,'invalid address');
		bool old_user = crops[user].remove(pid);
		if(old_user && pools[pid].userCount >=1){
			pools[pid].userCount -= 1;
		}
		emit Quit(pid,msg.sender,user);
	}
	
}
