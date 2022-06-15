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

  // test
  //const masterchef_addr = '0x4b3f5a330A64D3CFAa33ba6E2D2936a195904f38';
  //const vestingMaster_addr = '0x4d84d4FAfD8CBd8B28BC888c6EC714F55194A036';

  /*/ public test 
  const masterchef_addr = '0x6273638e3Be5770851E23bfcE27d69592BEDCd2c';
  const vestingMaster_addr = '0x04af25146Ad4806F1281c6E868872064334549aF';
  //*/

  // cube-mainnet
  //const masterchef_addr = '';
  //const vestingMaster_addr = '';

  //*/ public test 
  const masterchef_addr = '0x2125fc82ac71b640B7F680F89F0A5ee8D5372D8C';
  const vestingMaster_addr = '0xF6e501eAfb16B62c316d01e797A8105005721324';
  //*/

  const MasterChef= await ethers.getContractFactory("MasterChef");
  const masterchef= await MasterChef.attach(masterchef_addr);
  const setVestingMaster = await masterchef.updateVestingMaster(vestingMaster_addr);
  await setVestingMaster.wait();
  const vestingMaster = await masterchef.vestingMaster();
  console.log("set new vestingMaster",vestingMaster);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
