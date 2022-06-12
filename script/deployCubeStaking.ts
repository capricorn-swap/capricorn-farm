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

  const wcube = '0xB9164670A2F388D835B868b3D0D441fa1bE5bb00';
  const rewardToken = '0xc4D424aaCC8867f9f79FBCa88181E518e33eF178';
  const rewardPerBlock = "10000000000000000000";
  const startBlock = 790000;
  const endBlock = 1000000;
  const admin = deployer.address;
  const CubeStaking= await ethers.getContractFactory("CubeStaking");
  const cubeStaking= await CubeStaking.deploy(wcube,rewardToken,rewardPerBlock,startBlock,endBlock,admin);
  await cubeStaking.deployed();
  console.log("deploy cubeStaking",cubeStaking.address);

  /*

  const old_cubeStaking_addr = '0x47175993a73dC692Cd8C26E2f69235377BD0B01d'
  const old_cubeStaking = await CubeStaking.attach(old_cubeStaking_addr);

  //const RewardToken = await ethers.getContractFactory("IERC20");
  //const rewardTokenCntr = await RewardToken.attach(rewardToken);
  //const balance = await rewardTokenCntr.balanceOf(old_cubeStaking_addr); 
  const balance = '2494222796390474859937792'
  const withdraw_tx = await old_cubeStaking.emergencyRewardWithdraw(balance);
  await withdraw_tx.wait();
  console.log("cubeStaking.emergencyRewardWithdraw",balance);
  */


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
