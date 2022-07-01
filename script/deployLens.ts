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
  const feeToAddr = '0xa2b836ce2da26a10500e916bCB7F0e0b96Dd1319';
//*/

/* cube-testnet
  const masterchef = '0x6273638e3Be5770851E23bfcE27d69592BEDCd2c';
  const swapFactor = '0x7a1eba426aa389aac9b410cdfe3cef5d344e043f';
  const USDT = '0x9bd522cc85bd1bd6d069d5e273e46ccfee905493';
  const wcube = '0xB9164670A2F388D835B868b3D0D441fa1bE5bb00';
  const swapRouter = '0x14c02dc9b29ac28e852f740cba6722bc7308feb8';
//*/

/* cube-mainnet
  const masterchef = '0x441e22e8cC8c3cfa14086a78ED130e1841307860';
  const swapFactor = '0x33CB4150f3ADFCD92fbFA3309823A2a242bF280f';
  const USDT = '0x79F1520268A20c879EF44d169A4E3812D223C6de';

  const wcube = '0x9d3f61338d6eb394e378d28c1fd17d5909ac6591';
  const swapRouter = '0x34c385dd9015d663830a37CD2E75818fda6C605f';
  const feeToAddr = '0x37e45820279efefb805f71707883c438bed9e0d4'
//*/


    // internal test env 
    // working on
    const factory = "0xD7242029Ec91D8DB067DDC65a844EE2fE1071ba2" 
    // 
    const factory1 = "0x3F7B421102FDc34B39CE79B5A5A820892C253DdC" 
    const factory2 = "0x4EBadD989771a1eB2BCB26F2A127E69D414D2f82"

    const user01 = "0xb94e81Bf8148fce5A070cB146c5e2c113E6597B8"
    const user02 = "0xCc1FeC6Ec19d53470e26171B01bE4e61b5c9f16E"

    const lensAdd = "0x05dFaA9A03A04f881e5161d38B74c3A95973dE14"
    const IFOLens = await ethers.getContractFactory("IFOLens");

    const lens = await IFOLens.attach(lensAdd);


    // const lens = await IFOLens.deploy();
    // await lens.deployed()
    console.log("lensAddress:",lens.address)

    const setwork = await lens.SetWorkingFactory(factory);

    await setwork.wait();
    console.log("SetWorkingFactory finished");

    const workFactory = await lens.factoryOnWork();

    console.log("WorkingFactory is :",workFactory)

    const addf = await lens.AddFactorys([factory,factory1,factory2]);
    await addf.wait();

    console.log("AddFactorys finish");

    const crops01 = await lens.getCrops(user01);
    console.log("crops01:",crops01)
    const crops02 = await lens.getCrops(user02);
    console.log("crops02:",crops02)

    const seeds01 = await lens.getSeeds(user02);
    console.log("seeds01:",seeds01)

    const verifiedPools = await lens.getVerifiedPools();

    console.log("verifiedPools:",verifiedPools)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});