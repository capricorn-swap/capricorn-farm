// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

interface IWCUBE {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
}

contract CubeStaking is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        bool inWhiteList;
        uint256 pending;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. CORNs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CORNs distribution occurs.
        uint256 accCornPerShare; // Accumulated CORNs per share, times 1e12. See below.
    }

    // The REWARD TOKEN
    IERC20 public rewardToken;

    // adminAddress
    address public adminAddress;


    // WCUBE
    address public immutable WCUBE;

    // CORN tokens created per block.
    uint256 public rewardPerBlock;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    // limit 10 CUBE here
    uint256 public limitAmount = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when CORN mining starts.
    uint256 public startBlock;
    // The block number when CORN mining ends.
    uint256 public bonusEndBlock;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        IERC20 _wcube,
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        address _adminAddress
    ) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        adminAddress = _adminAddress;
        WCUBE = address(_wcube);

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _wcube,
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            accCornPerShare: 0
        }));

        totalAllocPoint = 1000;

    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    receive() external payable {
        assert(msg.sender == WCUBE); // only accept CUBE via fallback from the WCUBE contract
    }

    // Update admin address by the previous dev.
    function setAdmin(address _adminAddress) public onlyOwner {
        adminAddress = _adminAddress;
    }

    function addWhiteList(address [] calldata _whitelistAddresses) public onlyAdmin {
        for(uint i=0; i < _whitelistAddresses.length; i++){
            userInfo[_whitelistAddresses[i]].inWhiteList = true;
        }
    }

    function removeWhiteList(address [] calldata _whitelistAddresses) public onlyAdmin {
        for(uint i=0; i < _whitelistAddresses.length; i++){
            userInfo[_whitelistAddresses[i]].inWhiteList = false;
        }
    }

    // Set the limit amount. Can only be called by the owner.
    function setLimitAmount(uint256 _amount) public onlyOwner {
        limitAmount = _amount;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[_user];
        uint256 accCornPerShare = pool.accCornPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cornReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCornPerShare = accCornPerShare.add(cornReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCornPerShare).div(1e12).sub(user.rewardDebt).add(user.pending);
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
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 cornReward = multiplier.mul(rewardPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accCornPerShare = pool.accCornPerShare.add(cornReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Stake tokens to SmartChef
    function deposit() public payable {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];

        require (block.number < bonusEndBlock,'finished');
        require (user.amount.add(msg.value) <= limitAmount, 'exceed the top');
        require (user.inWhiteList, 'not in white list');

        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCornPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                user.pending = user.pending.add(pending);
            }
        }
        if(msg.value > 0) {
            IWCUBE(WCUBE).deposit{value: msg.value}();
            assert(IWCUBE(WCUBE).transfer(address(this), msg.value));
            user.amount = user.amount.add(msg.value);
        }

        user.rewardDebt = user.amount.mul(pool.accCornPerShare).div(1e12);

        emit Deposit(msg.sender, msg.value);
    }

    function safeTransferCUBE(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        // (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    // Withdraw tokens from STAKING.
    function withdraw(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accCornPerShare).div(1e12).sub(user.rewardDebt);

        user.pending = user.pending.add(pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accCornPerShare).div(1e12);

        if(block.number > bonusEndBlock && user.pending > 0){
            uint256 reward = user.pending;
            user.pending = 0;
            rewardToken.safeTransfer(address(msg.sender), reward);
        }

        if(_amount > 0) {
            IWCUBE(WCUBE).withdraw(_amount);
            safeTransferCUBE(address(msg.sender), _amount);
        }

        emit Withdraw(msg.sender, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.pending = 0;
    }

    // Withdraw token. EMERGENCY ONLY.
    function emergencyTokenWithdraw(address token, uint256 _amount) public onlyOwner {
        require(token != WCUBE);
        require(_amount <= IERC20(token).balanceOf(address(this)), 'not enough token');
        IERC20(token).safeTransfer(address(msg.sender), _amount);
    }

}
