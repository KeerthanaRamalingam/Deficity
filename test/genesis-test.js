const { expect } = require("chai");
const { intToBuffer } = require("ethjs-util");
const { ethers } = require("hardhat");

let owner, addr1, addr2, addrs;
let mainToken;
let genesis;

describe("genesis Pool", function () {
    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        const MainToken = await ethers.getContractFactory("BEP20TokenImplementation");
        mainToken = await MainToken.connect(owner).deploy();
        await mainToken.deployed();

        const Genesis = await ethers.getContractFactory("GenesisPool");
        genesis = await Genesis.connect(owner).deploy(mainToken.address);
        await genesis.deployed();

        await mainToken.initialize("Test", "Test", 18, 100000, true, owner.address);

    });

    it("Stake", async function () {
        const transferCall = await mainToken.connect(owner).transfer(addr1.address, 1000);
        await transferCall.wait();
        expect(await mainToken.balanceOf(addr1.address)).to.equal(1000);

        const approveCall = await mainToken.connect(addr1).approve(genesis.address, 1000);
        await approveCall.wait();
        expect(await mainToken.allowance(addr1.address, genesis.address)).to.equal(1000);

        const stakecall = await genesis.connect(addr1).stake(1000);
        await stakecall.wait();
        expect(await mainToken.balanceOf(addr1.address)).to.equal(0);

        await expect(
            genesis.connect(addr1).stake(1000)
        ).to.be.revertedWith('User Staked already');

        expect(await genesis.rewardsCovered()).to.equal(4000);

        expect(await genesis.totalStaked()).to.equal(1000);

        await ethers.provider.send('evm_increaseTime', [7775000]);
        await ethers.provider.send('evm_mine');

        await expect(
            genesis.connect(addr1).unStake()
        ).to.be.revertedWith('UnStake not allowed');

        await ethers.provider.send('evm_increaseTime', [1000]);
        await ethers.provider.send('evm_mine');

        const gtransferCall = await mainToken.connect(owner).transfer(genesis.address, 4000);
        await gtransferCall.wait();

        const unstakecall = await genesis.connect(addr1).unStake();
        await unstakecall.wait();
        expect(await mainToken.balanceOf(addr1.address)).to.equal(5000);

        expect(await genesis.totalStaked()).to.equal(0);
    })
});