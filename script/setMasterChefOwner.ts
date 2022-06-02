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

  /*/ // test
  const masterchef_addr = '0x4b3f5a330A64D3CFAa33ba6E2D2936a195904f38';
  const smartcheffactory_addr = '0x479EcE2b84C4fFb53F5E551fC5d924D3f87ab922';

  const signer_addr = '0x2c76fe561cce48b50c4f918ab0affe940d57bfeb';
  //*/

  //* // public test
  const masterchef_addr = '0x6273638e3Be5770851E23bfcE27d69592BEDCd2c';
  const smartcheffactory_addr = '0x25070baCb0c3CcB2Db44d54dD02f5dB50024204d';

  const signer_addr = '0x2fd6cf4118cffabd8b7163651fecba6517c81e5f';
  //*/
  
  const MasterChef= await ethers.getContractFactory("MasterChef");
  const masterchef= await MasterChef.attach(masterchef_addr);
  const setMasterChefOwner = await masterchef.transferOwnership(signer_addr);
  await setMasterChefOwner.wait();
  const masterChefOwner = await masterchef.owner();
  console.log("set MasterChef Owner",masterChefOwner);

  const SmartChefFactory= await ethers.getContractFactory("SmartChefFactory");
  const smartchef= await SmartChefFactory.attach(smartcheffactory_addr);
  const setSmartChefOwner = await smartchef.transferOwnership(signer_addr);
  await setSmartChefOwner.wait();
  const smartChefOwner = await smartchef.owner();
  console.log("set SmartChefFactory Owner",smartChefOwner);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

