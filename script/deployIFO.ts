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


/* cube-testnet internal
  const masterchef = '0x4b3f5a330A64D3CFAa33ba6E2D2936a195904f38';
  const swapFactor = '0xc524aed399c4dc98c42af8fab58f440ff5cd36f0';
  const USDT = '0x9bd522cc85bd1bd6d069d5e273e46ccfee905493';

  const wcube = '0xB9164670A2F388D835B868b3D0D441fa1bE5bb00';
  const swapRouter = '0xc82edd7f219d0771f4bc45353d67fc4c8d34c1ee';
//*/

/* cube-testnet
  const masterchef = '0x6273638e3Be5770851E23bfcE27d69592BEDCd2c';
  const swapFactor = '0x7a1eba426aa389aac9b410cdfe3cef5d344e043f';
  const USDT = '0x9bd522cc85bd1bd6d069d5e273e46ccfee905493';

  const wcube = '0xB9164670A2F388D835B868b3D0D441fa1bE5bb00';
  const swapRouter = '0x14c02dc9b29ac28e852f740cba6722bc7308feb8';
//*/

//* cube-mainnet
  const masterchef = '0x441e22e8cC8c3cfa14086a78ED130e1841307860';
  const swapFactor = '0x33CB4150f3ADFCD92fbFA3309823A2a242bF280f';
  const USDT = '0x79F1520268A20c879EF44d169A4E3812D223C6de';

  const wcube = '0x9d3f61338d6eb394e378d28c1fd17d5909ac6591';
  const swapRouter = '0x34c385dd9015d663830a37CD2E75818fda6C605f';
  const feeToAddr = '0x37e45820279efefb805f71707883c438bed9e0d4'
//*/

  const Validator= await ethers.getContractFactory("Validator");
  const validator = await Validator.deploy(masterchef, swapFactor,USDT);
  await validator.deployed();
  const validator_addr = validator.address;
  console.log("deploy validator",validator.address);

  const IFOFactory = await ethers.getContractFactory("IFOFactory");
  const ifoFactory = await IFOFactory.deploy(wcube,swapRouter,validator_addr);
  await ifoFactory.deployed();
  const ifoFactory_addr = ifoFactory.address;
  console.log("deploy ifoFactory",ifoFactory.address);

  // setMinTime
  const setMinTime = await ifoFactory.setMinTime(600);
  await setMinTime.wait();
  console.log("setMinTime",await ifoFactory.MIN_TIME());

  // setMinPeriod
  const setMinPeriod = await ifoFactory.setMinPeriod(30);
  await setMinPeriod.wait();
  console.log("setMinPeriod",await ifoFactory.MIN_PERIOD());

  // setFeeTo
  const setFeeTo = await ifoFactory.setFeeTo(feeToAddr);
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


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
