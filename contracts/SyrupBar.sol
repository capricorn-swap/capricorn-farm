pragma solidity 0.6.2;

import "../../capricorn-swap-lib/contracts/access/Ownable.sol";
import "../../capricorn-swap-lib/contracts/math/SafeMath.sol";

import "./CapricornToken.sol";

// SyrupBar with Governance.
contract SyrupBar is Ownable{
	using SafeMath for uint256;

    // The CAPRICORN TOKEN!
    CapricornToken public cpct;
	uint256 public LOCK_DAYS = 300;
	uint256 public lastRewardDay;
	uint256 public accCapricornPerDay;
	uint256 public expiredCapricornPerDay;
	uint256 public unlockReward;
	uint256 public rewardDebt;
	mapping(uint256=>uint256) lockRecord;


    constructor(
        CapricornToken _cpct
    ) public {
        cpct = _cpct;
    }

    // Safe cake transfer function, just in case if rounding error causes pool to not have enough CAKEs.
    function safeCapricornTransfer(address _to, uint256 _amount) public onlyOwner {
        uint256 capricornBal = cpct.balanceOf(address(this));
        if (_amount > capricornBal) {
            cpct.transfer(_to, capricornBal);
        } else {
            cpct.transfer(_to, _amount);
        }
    }

	// update record
	function updateDevRecord() internal {
		uint256 day = block.timestamp/(3600*24);
		if(lastRewardDay == 0){
			lastRewardDay = day;
		}
		unlockReward += accCapricornPerDay*(day-lastRewardDay);
		while(lastRewardDay < day){
			expiredCapricornPerDay += lockRecord[lastRewardDay-LOCK_DAYS]/LOCK_DAYS;
			unlockReward = unlockReward.sub(expiredCapricornPerDay);
			lastRewardDay ++;
		}
	}

	// Lock dev reward
	function lockDevReward(uint amount) public onlyOwner{
		updateDevRecord();
		uint256 day = block.timestamp/(3600*24);
		lockRecord[day] += amount;
		accCapricornPerDay += amount/LOCK_DAYS;
	}

	// Unlock dev reward
	function unlockDevReward() public onlyOwner returns(uint256 amount){
		updateDevRecord();
		amount = pendingDevReward();
		rewardDebt += amount;
	}

	// Pending dev reward
	function pendingDevReward() public view returns(uint256 pending){
		uint256 day = block.timestamp/(3600*24);
		if(lastRewardDay == 0){
			return 0;
		}
		uint256 unlockPending = accCapricornPerDay.mul(day - lastRewardDay);
		uint256 expiredPending = expiredCapricornPerDay;
		uint256 _lastRewardDay = lastRewardDay;
		while(_lastRewardDay < day){
			expiredPending += lockRecord[lastRewardDay-LOCK_DAYS]/LOCK_DAYS;
			unlockPending = unlockReward.sub(expiredPending);
			_lastRewardDay ++;
		}
		pending = unlockReward.add(unlockPending).sub(rewardDebt);
	}
}
