// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const CapricornToken= await ethers.getContractFactory("CapricornToken");
  const CORN = await CapricornToken.deploy();
  await CORN.deployed();
  console.log("CapricornToken deployed to:", CORN.address);

  const Syrup= await ethers.getContractFactory("SyrupBar");
  const syrup= await Syrup.deploy(CORN.address);
  await syrup.deployed();
  console.log("SyrupBar deployed to:", syrup.address);

  const CORNPerBlock = "45000000000000000000";
  const startBlock = 570000;
  const MasterChef= await ethers.getContractFactory("MasterChef");
  const masterchef= await MasterChef.deploy(CORN.address,syrup.address,deployer.address,CORNPerBlock,startBlock);
  await masterchef.deployed();
  console.log("MasterChef deployed to:", masterchef.address);

/*
  const wcube = '0xB9164670A2F388D835B868b3D0D441fa1bE5bb00';
  const rewardToken = CORN.address;
  const rewardPerBlock = "45000000000000000000";
  const startBlock = 200000;
  const endBlock = 400000;
  const admin = deployer.address;
  const CubeStaking= await ethers.getContractFactory("CubeStaking");
  const cubeStaking= await CubeStaking.deploy(wcube,rewardToken,rewardPerBlock,startBlock,endBlock,admin,wcube);
  await cubeStaking.deployed();
  console.log("deploy cubeStaking",cubeStaking.address);
*/

  const SmartChefFactory= await ethers.getContractFactory("SmartChefFactory");
  const smartcheffactory= await SmartChefFactory.deploy();
  await smartcheffactory.deployed();
  console.log("SmartChefFactory deployed to:", smartcheffactory.address);

  
/*
  const masterchef_addr = '0x4C9e77C722693F119Fda85D8Ff5e4b9E64258AbC';

  const CapricornToken= await ethers.getContractFactory("CapricornToken");
  const CORN_addr = '0x9020d0EF9A973319163Ee0C8b9580813b8c459f5';
  const CORN = CapricornToken.attach(CORN_addr);

  const SyrupBar= await ethers.getContractFactory("SyrupBar");
  const syrup_addr = '0xc06383f846537271843E2dFc8F1f96a6798F415D';
  const syrup = SyrupBar.attach(syrup_addr);
*/
  const mintAmount = "50000000000000000000000000"
  const firstMint= await CORN.mint(deployer.address,mintAmount);
  // wait until the transaction is mined
  await firstMint.wait();
  console.log("firstMint:",await CORN.balanceOf(deployer.address));
  


  const setCornOwner = await CORN.transferOwnership(masterchef.address);
  // wait until the transaction is mined
  await setCornOwner.wait();
  console.log("set CPCT owner:",await CORN.owner());

  const setSyrupBarOwner = await syrup.transferOwnership(masterchef.address);
  // wait until the transaction is mined
  await setSyrupBarOwner.wait();
  console.log("set SyrupBar owner:",await syrup.owner());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
