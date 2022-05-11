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
  const cpct = await CapricornToken.deploy();
  await cpct.deployed();
  console.log("CapricornToken deployed to:", cpct.address);

  const Syrup= await ethers.getContractFactory("SyrupBar");
  const syrup= await Syrup.deploy(cpct.address);
  await syrup.deployed();
  console.log("SyrupBar deployed to:", syrup.address);

  const cpctPerBlock = "45000000000000000000";
  const startBlock = 100;
  const MasterChef= await ethers.getContractFactory("MasterChef");
  const masterchef= await MasterChef.deploy(cpct.address,syrup.address,deployer.address,cpctPerBlock,startBlock);
  await masterchef.deployed();
  console.log("MasterChef deployed to:", masterchef.address);

  const SmartChefFactory= await ethers.getContractFactory("SmartChefFactory");
  const smartcheffactory= await SmartChefFactory.deploy();
  await smartcheffactory.deployed();
  console.log("SmartChefFactory deployed to:", smartcheffactory.address);

  const mintAmount = "50000000000000000000000000"
  const firstMint= await cpct.mint(deployer.address,mintAmount);
  // wait until the transaction is mined
  await firstMint.wait();
  console.log("firstMint:",await cpct.balanceOf(deployer.address));

  const setCpctOwner = await cpct.transferOwnership(masterchef.address);
  // wait until the transaction is mined
  await setCpctOwner.wait();
  console.log("set CPCT owner:",await cpct.owner());

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
