// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';
import "./interfaces/IIFOFactory.sol";
import "./interfaces/IIFOPool.sol";



// verifiedPools

// myCrops

// mySeeds


contract IFOLens is Ownable{

    address public  factoryOnWork;
    address[] public factorys;
    mapping(address => bool) factoryIn;

    function AddFactorys(address[] memory factory) external onlyOwner {
        for(uint i = 0;i < factory.length;i++){
            if(!factoryIn[factory[i]]){
                require(IIFOFactory(factory[i]).validator() != address(0), "not factory");
                factorys.push(factory[i]);
                factoryIn[factory[i]] = true;
            }
        }
    }

    function SetWorkingFactory(address factory) external onlyOwner {
        factoryOnWork = factory;
    }

    function getCrops(address user) external view returns(IIFOFactory.PoolInfo [] memory _pools){
        uint poolsLength;
        uint index;
        for(uint i = 0; i < factorys.length; i++){
            IIFOFactory.PoolInfo[] memory myCrops = IIFOFactory(factorys[i]).myCrops(user);
            poolsLength += myCrops.length;
        }
        _pools = new IIFOFactory.PoolInfo[](poolsLength);
        for(uint i = 0; i < factorys.length; i++){
            IIFOFactory.PoolInfo[] memory myCrops = IIFOFactory(factorys[i]).myCrops(user);
            for(uint j = 0; j < myCrops.length;j++){
                _pools[index] = (myCrops[j]);
                index++;
            }
        }
    }

    function getSeeds(address user) external view returns(IIFOFactory.PoolInfo [] memory _pools) {
        uint poolsLength;
        uint index;
        for(uint i = 0; i < factorys.length; i++){
            IIFOFactory.PoolInfo[] memory mySeeds = IIFOFactory(factorys[i]).mySeeds(user);
            poolsLength += mySeeds.length;
        }
        _pools = new IIFOFactory.PoolInfo[](poolsLength);
        for(uint i = 0; i < factorys.length; i++){
            IIFOFactory.PoolInfo[] memory mySeeds = IIFOFactory(factorys[i]).mySeeds(user);
            for(uint j = 0; j < mySeeds.length;j++){
                _pools[index] = (mySeeds[j]);
                index++;
            }
        }
    }

    function getVerifiedPools() external view returns(IIFOFactory.PoolInfo [] memory _pools) {
        uint poolsLength;
        uint index;
        for(uint i = 0; i < factorys.length; i++){
            IIFOFactory.PoolInfo[] memory verifiedPools = IIFOFactory(factorys[i]).verifiedPools();
            poolsLength += verifiedPools.length;
        }
        _pools = new IIFOFactory.PoolInfo[](poolsLength);
        for(uint i = 0; i < factorys.length; i++){
            IIFOFactory.PoolInfo[] memory verifiedPools = IIFOFactory(factorys[i]).verifiedPools();
            for(uint j = 0; j < verifiedPools.length;j++){
                _pools[index] = (verifiedPools[j]);
                index++;
            }
        }
    }
}