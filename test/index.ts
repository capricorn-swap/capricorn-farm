import { expect } from "chai";
import { ethers } from "hardhat";

describe("Farm contracts", function () {

    before(async function () {
        this.addrs = await ethers.getSigners();
        this.owner = this.addrs[0].address;
    });

    describe("Deploy and init contracts", function () {
      it("Deploy CapricornToken", async function () {
        this.CapricornToken= await ethers.getContractFactory("CapricornToken");
        this.corn = await this.CapricornToken.deploy();
        await this.corn.deployed();
        console.log("deploy CORN",this.corn.address)
        expect(await this.corn.owner()).to.equal(this.owner);
      });

      it("Deploy Syrupbar", async function () {
        this.Syrup= await ethers.getContractFactory("SyrupBar");
        this.syrup= await this.Syrup.deploy(this.corn.address);
        await this.syrup.deployed();
        console.log("deploy SyrupBar",this.syrup.address);
        expect(await this.syrup.owner()).to.equal(this.owner);
      });

      it("Deploy SmartChefFactory", async function () {
        this.SmartChefFactory= await ethers.getContractFactory("SmartChefFactory");
        this.smartcheffactory= await this.SmartChefFactory.deploy();
        await this.smartcheffactory.deployed();
        console.log("deploy SmartChefFactory",this.smartcheffactory.address);
        expect(await this.smartcheffactory.owner()).to.equal(this.owner);
      });

      it("Deploy MasterChef", async function () {
        this.MasterChef= await ethers.getContractFactory("MasterChef");
        this.masterchef= await this.MasterChef.deploy(this.corn.address,this.syrup.address,this.owner,"45000000000000000000",100);
        await this.masterchef.deployed();
        console.log("deploy MasterChef",this.masterchef.address);
        expect(await this.masterchef.owner()).to.equal(this.owner);
      });

      it("Deploy CubeStaking", async function () {
        const wcube = '0xB9164670A2F388D835B868b3D0D441fa1bE5bb00';
        const rewardToken = this.corn.address;
        const rewardPerBlock = "45000000000000000000";
        const startBlock = 100;
        const endBlock = 1000;
        const admin = this.owner;
        this.CubeStaking= await ethers.getContractFactory("CubeStaking");
        this.cubeStaking= await this.CubeStaking.deploy(wcube,rewardToken,rewardPerBlock,startBlock,endBlock,admin,wcube);
        await this.cubeStaking.deployed();
        console.log("deploy cubeStaking",this.cubeStaking.address);
        expect(await this.cubeStaking.owner()).to.equal(this.owner);
      });

      it("first mint corn",async function(){
        const firstMint= await this.corn.mint(this.owner,50000000);
        // wait until the transaction is mined
        await firstMint.wait();
        expect(await this.corn.balanceOf(this.owner)).to.equal(50000000);
      });

      it("set corn owner to masterchef",async function(){
        const setOwner = await this.corn.transferOwnership(this.masterchef.address);
        // wait until the transaction is mined
        await setOwner.wait();
        expect(await this.corn.owner()).to.equal(this.masterchef.address);
      });

      it("set syrup owner to masterchef",async function(){
        const setOwner = await this.syrup.transferOwnership(this.masterchef.address);
        // wait until the transaction is mined
        await setOwner.wait();
        expect(await this.syrup.owner()).to.equal(this.masterchef.address);
      });

    });

});

