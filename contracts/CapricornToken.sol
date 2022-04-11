pragma solidity 0.6.2;

import "../../capricorn-swap-lib/contracts/token/CRC20/CRC20.sol";

// CakeToken with Governance.
contract CapricornToken is CRC20('CapricornSwap Token', 'CPCT') {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

}
