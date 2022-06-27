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

  const masterchef = '0x6273638e3Be5770851E23bfcE27d69592BEDCd2c';
  const swapFactor = '0x7a1eba426aa389aac9b410cdfe3cef5d344e043f';
  const USDT = '0x9bd522cc85bd1bd6d069d5e273e46ccfee905493';

  const Validator= await ethers.getContractFactory("Validator");
  const validator = await Validator.deploy(masterchef, swapFactor,USDT);
  await validator.deployed();
  const validator_addr = validator.address;
  console.log("deploy validator",validator.address);

  const wcube = '0xB9164670A2F388D835B868b3D0D441fa1bE5bb00';
  const swapRouter = '0x14c02dc9b29ac28e852f740cba6722bc7308feb8';

  const IFOFactory = await ethers.getContractFactory("IFOFactory");
  const ifoFactory = await IFOFactory.deploy(wcube,swapRouter,validator_addr);
  await ifoFactory.deployed();
  const ifoFactory_addr = ifoFactory.address;
  console.log("deploy ifoFactory",ifoFactory.address);

  // setFeeTo
  const setMinTime = await ifoFactory.setMinTime(0);
  await setMinTime.wait();
  console.log("setMinTime",await ifoFactory.MIN_TIME());

  // setFeeTo
  const setFeeTo = await ifoFactory.setFeeTo(deployer.address);
  await setFeeTo.wait();
  console.log("setFeeTo",await ifoFactory.feeTo());

  // setOpenfeeToken
  const setOpenfeeToken = await ifoFactory.setOpenfeeToken(USDT);
  await setOpenfeeToken.wait();
  console.log("setOpenfeeToken",await ifoFactory.openfeeToken());

  // setOpenfeeAmount
  const setOpenfeeAmount = await ifoFactory.setOpenfeeAmount("20000000000000000000");
  await setOpenfeeAmount.wait();
  console.log("setOpenfeeAmount",await ifoFactory.openfeeAmount());

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
