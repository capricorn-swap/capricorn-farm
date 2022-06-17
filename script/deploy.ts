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
  const startBlock = 436315;
  const devaddr = '0xf263720272cd382b43abf6ab73f09cf18e1372cd';
  const MasterChef= await ethers.getContractFactory("MasterChef");
  const masterchef= await MasterChef.deploy(CORN.address,syrup.address,devaddr,CORNPerBlock,startBlock);
  await masterchef.deployed();
  console.log("MasterChef deployed to:", masterchef.address);


  const SmartChefFactory= await ethers.getContractFactory("SmartChefFactory");
  const smartcheffactory= await SmartChefFactory.deploy();
  await smartcheffactory.deployed();
  console.log("SmartChefFactory deployed to:", smartcheffactory.address);


  const add1 = "0x11B17722F0E877Aa5B4CbEDCC448aD5CC97E8268";
  const mintAmount1 = "20000000000000000000000000";
  const firstMint1= await CORN.mint(add1,mintAmount1);
  // wait until the transaction is mined
  await firstMint1.wait();
  console.log("Mint:",await CORN.balanceOf(add1));

  const add2 = "0xfdE3ee0f427AD75A5a057F26Ab87E051BE44F6Ef";
  const mintAmount2 = "2000000000000000000000000";
  const firstMint2= await CORN.mint(add2,mintAmount2);
  // wait until the transaction is mined
  await firstMint2.wait();
  console.log("Mint:",await CORN.balanceOf(add2));

  const add3 = "0x3B024d206358aA2c6794219Eed418f5f903F567C";
  const mintAmount3 = "3000000000000000000000000";
  const firstMint3= await CORN.mint(add3,mintAmount3);
  // wait until the transaction is mined
  await firstMint3.wait();
  console.log("Mint:",await CORN.balanceOf(add3));

  const add4 = "0xCaaD0A0840ed34D138d9961b3903185064F13BbE";
  const mintAmount4 = "25000000000000000000000000";
  const firstMint4= await CORN.mint(add4,mintAmount4);
  // wait until the transaction is mined
  await firstMint4.wait();
  console.log("Mint:",await CORN.balanceOf(add4));


  const setCornOwner = await CORN.transferOwnership(masterchef.address);
  // wait until the transaction is mined
  await setCornOwner.wait();
  console.log("set Corn owner:",await CORN.owner());

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
