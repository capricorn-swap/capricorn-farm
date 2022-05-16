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

  const masterchef_addr = '0x6Be5D364316438e4b5a59bc02d4819647131b74d';
  const vestingMaster_addr = '0x5A828194035906B2722CBfa0aA351E51b8228A6F';
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
