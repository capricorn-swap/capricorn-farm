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

  const admin = deployer.address;
  const CubeStaking= await ethers.getContractFactory("CubeStaking");

  //const cubeStaking_addr = '0x4d6e5FB5d72244F29115Dee3c678A29e4495b954'
  //const cubeStaking_addr = '0xeA5162c96cDa081B044d81F31B3cFEDe5557f0CA'
  const cubeStaking_addr = '0x0187BA585271A4BBcB9D7A42221ea902f434e59F'
  const cubeStaking = await CubeStaking.attach(cubeStaking_addr);
  const whiteList = [
'0x9eD2b11E3fbdc19E38debdC1cC934B9fb6d7b61e',
'0xb94e81Bf8148fce5A070cB146c5e2c113E6597B8',
'0xf3c3dae63269598c61fac64ab934d004ad156ca4',
'0xb9891f9c09bbd6821fd94969333125c177010385',
'0x0a4583a59769291b7f6d9ad7770b94686888e0ce',
'0x787c3d7ffa76bdff6e6965ca237046468294bc6b',
'0x26744d6b405f81edc50fa6315943d03505dff76b',
'0x590ce943461f78dd48d56d477722e4ebba4fc1a9',
'0xaa3f85011a02a60ca56405b5f0fabc068f54e2f7',
'0x872d1e3049798908548a3a2a66163fe19c1d9b46',
'0xac8bcfadfda7bde5aa632ca991f7cb1524784eb8',
'0x210be791807599b608b863477f2506121a1fbef0',
'0x2c76fe561cce48b50c4f918ab0affe940d57bfeb',
'0xf3c3dae63269598c61fac64ab934d004ad156ca4',
'0xb9891f9c09bbd6821fd94969333125c177010385',
'0x0a4583a59769291b7f6d9ad7770b94686888e0ce',
'0x210be791807599b608b863477f2506121a1fbef0',
'0x787c3d7ffa76bdff6e6965ca237046468294bc6b',
'0x26744d6b405f81edc50fa6315943d03505dff76b',
'0x590ce943461f78dd48d56d477722e4ebba4fc1a9',
'0xaa3f85011a02a60ca56405b5f0fabc068f54e2f7',
'0x872d1e3049798908548a3a2a66163fe19c1d9b46',
'0xCc1FeC6Ec19d53470e26171B01bE4e61b5c9f16E',
'0xf58DBD95c957cC381a76B9Aae401779a5B24e06a',

  ]

  //const add_tx = await cubeStaking.batchSetWhiteList(whiteList);
  //await add_tx.wait();

  for( var i in whiteList){
    console.log(i);
    const addr = whiteList[i];
    //const tx = await cubeStaking.setWhiteList(addr);
    //await tx.wait();
    const userInfo1 = await cubeStaking.userInfo(addr);
    console.log(userInfo1);
    const isInWhiteList = userInfo1['inWhiteList']
    console.log(addr," is in white list",isInWhiteList)
  }


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
