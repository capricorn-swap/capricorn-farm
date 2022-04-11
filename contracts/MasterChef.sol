pragma solidity 0.6.2;

import '../../capricorn-swap-lib/contracts/math/SafeMath.sol';
import '../../capricorn-swap-lib/contracts/token/CRC20/ICRC20.sol';
import '../../capricorn-swap-lib/contracts/token/CRC20/SafeCRC20.sol';
import '../../capricorn-swap-lib/contracts/access/Ownable.sol';

import "./CapricornToken.sol";
import "./SyrupBar.sol";



// MasterChef is the master of Capricorn. He can make Capricorn and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Capricorn is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeCRC20 for ICRC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of CPCTs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accCapricornPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accCapricornPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        ICRC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. CPCTs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CPCTs distribution occurs.
        uint256 accCapricornPerShare; // Accumulated CPCTs per share, times 1e12. See below.
    }

    // The CPCT TOKEN!
    CapricornToken public cpct;
    // The SYRUP TOKEN!
    SyrupBar public syrup;
    // Dev address.
    address public devaddr;
    // CPCT tokens created per block.
    uint256 public cpctPerBlock;
    // Bonus muliplier(percent) for early cpct makers.
    uint256 public BONUS_MULTIPLIER = 100;
	// Max bps
	uint256 public MAX_SHARE = 10000;
	// Burn share bps 
	uint256 public BURN_SHARE = 0;
	// Dev share bps
	uint256 public DEV_SHARE = 2500;
	// Pool share bps
	uint256 public POOL_SHARE = 3333;
	// Farm burn share bps
	uint256 public FARM_BURN_SHARE = 0;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CPCT mining starts.
    uint256 public startBlock;
	// The block number when CPCT last mined.
	uint256 public lastMinedBlock;
	// Total Dev Reward
	uint256 public totalDevReward = 0;
	// Max Dev Reward
	uint256 public MAX_DEV_REWARD = 3*10**26;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        CapricornToken _cpct,
        SyrupBar _syrup,
        address _devaddr,
        uint256 _cpctPerBlock,
        uint256 _startBlock
    ) public {
        cpct = _cpct;
        syrup = _syrup;
        devaddr = _devaddr;
        cpctPerBlock = _cpctPerBlock;
        startBlock = _startBlock;
		lastMinedBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _cpct,
            allocPoint: 10000,
            lastRewardBlock: startBlock,
            accCapricornPerShare: 0
        }));

        totalAllocPoint = 10000;

    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

	function updateBurnShare(uint _burnShare) public onlyOwner{
		require(_burnShare <= MAX_SHARE,'too large share');
		BURN_SHARE = _burnShare;
	}

	function updateDevShare(uint _devShare) public onlyOwner{
		require(_devShare <= MAX_SHARE,'too large share');
		DEV_SHARE = _devShare;
	}

	function updatePoolShare(uint _poolShare) public onlyOwner{
		require(_poolShare <= MAX_SHARE,'too large share');
		massUpdatePools();
		POOL_SHARE = _poolShare;
		updateStakingPool();
	}

	function updateFarmBurnShare(uint _farmBurnShare) public onlyOwner{
		require(_farmBurnShare <= MAX_SHARE,'too large share');
		massUpdatePools();
		FARM_BURN_SHARE = _farmBurnShare;
		updateStakingPool();
	}

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

	function blockMint() public {
		if(block.number <= lastMinedBlock){
			return;
		}
		uint256 multiplier = getMultiplier(lastMinedBlock, block.number);
		uint256 cpctReward = multiplier.mul(cpctPerBlock);

		uint256 burnAmount = cpctReward.mul(BURN_SHARE).div(MAX_SHARE);
		uint256 devReward = cpctReward.sub(burnAmount).mul(DEV_SHARE).div(MAX_SHARE);
		uint256 syrupReward = cpctReward.sub(burnAmount).sub(devReward);
		if(burnAmount > 0){
			cpct.mint(address(1), burnAmount);
		}
		if(devReward > 0){
			uint devBurn = 0;
			if(totalDevReward.add(devReward) > MAX_DEV_REWARD){
				devBurn = totalDevReward.add(devReward).sub(MAX_DEV_REWARD);
			}
			devReward = devReward.sub(devBurn);
			if(devReward > 0){
				cpct.mint(address(syrup),devReward);
				syrup.lockDevReward(devReward);
				totalDevReward = totalDevReward.add(devReward);
			}
			if(devBurn > 0){
				cpct.mint(address(1),devReward);
			}
		}
		if(syrupReward > 0){
			uint256 farmBurn = syrupReward.mul(MAX_SHARE-POOL_SHARE).mul(FARM_BURN_SHARE).div(MAX_SHARE**2);
			syrupReward = syrupReward.sub(farmBurn);
			if(farmBurn>0)
				cpct.mint(address(1),farmBurn);
			cpct.mint(address(syrup),syrupReward);
		}
		lastMinedBlock = block.number;
	}

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, ICRC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accCapricornPerShare: 0
        }));
        updateStakingPool();
    }

    // Update the given pool's CPCT allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

	// keep pool[0] have the POOL_SHARE bps
    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
			uint256 p0Point = points.mul(MAX_SHARE).mul(POOL_SHARE).div(MAX_SHARE-FARM_BURN_SHARE).div(MAX_SHARE-POOL_SHARE);
            poolInfo[0].allocPoint = p0Point;
            totalAllocPoint = p0Point.add(points);
        }
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER).div(MAX_SHARE);
    }

    // View function to see pending CPCTs on frontend.
    function pendingCapricorn(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCapricornPerShare = pool.accCapricornPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
			uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
			uint256 syrupReward = multiplier.mul(cpctPerBlock).mul(MAX_SHARE-BURN_SHARE).mul(MAX_SHARE-DEV_SHARE).div(MAX_SHARE**2);
			uint256 farmBurn = syrupReward.mul(MAX_SHARE-POOL_SHARE).mul(FARM_BURN_SHARE).div(MAX_SHARE**2);
			uint256 cpctReward = (syrupReward.sub(farmBurn)).mul(pool.allocPoint).div(totalAllocPoint);
            accCapricornPerShare = accCapricornPerShare.add(cpctReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCapricornPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }


    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
		blockMint();
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
		uint256 syrupReward = multiplier.mul(cpctPerBlock).mul(MAX_SHARE-BURN_SHARE).mul(MAX_SHARE-DEV_SHARE).div(MAX_SHARE**2);
		uint256 farmBurn = syrupReward.mul(MAX_SHARE-POOL_SHARE).mul(FARM_BURN_SHARE).div(MAX_SHARE**2);
        uint256 cpctReward = (syrupReward.sub(farmBurn)).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accCapricornPerShare = pool.accCapricornPerShare.add(cpctReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for CPCT allocation.
    function deposit(uint256 _pid, uint256 _amount) public {

        require (_pid != 0, 'deposit CPCT by staking');

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCapricornPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeCapricornTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCapricornPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {

        require (_pid != 0, 'withdraw CPCT by unstaking');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCapricornPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeCapricornTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCapricornPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake CPCT tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCapricornPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeCapricornTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCapricornPerShare).div(1e12);

        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw CPCT tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accCapricornPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeCapricornTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accCapricornPerShare).div(1e12);

        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe cpct transfer function, just in case if rounding error causes pool to not have enough CPCTs.
    function safeCapricornTransfer(address _to, uint256 _amount) internal {
        syrup.safeCapricornTransfer(_to, _amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

	// withdraw dev reward from syrup
	function devWithdraw() public {
        require(msg.sender == devaddr, "dev: wut?");
		uint256 amount = syrup.unlockDevReward();
		require(amount > 0,'no reward');
		syrup.safeCapricornTransfer(msg.sender, amount);
	}
}
