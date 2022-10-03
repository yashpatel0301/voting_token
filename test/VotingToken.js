const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token contract", () => {
  let Token, token, owner, addr1, addr2;

  beforeEach(async () => {
    Token = await ethers.getContractFactory("VotingToken");
    token = await Token.deploy(1000,60);
    [owner, addr1, addr2, _] = await ethers.getSigners();
  });
  describe("Deployment", () => {
    it("Should Set the right owner", async () => {
      expect(await token.owner()).to.equal(owner.address);
    });

    it("Should apply the total supply of tokens to the owner", async () => {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });
    describe("Transactions", () => {
      it("Should be able to transfer token", async () => {
        await token.transfer(addr1.address, 50);
        const addr1Balance = await token.balanceOf(addr1.address);
        expect(addr1Balance).to.equal(50);

        await token.connect(addr1).transfer(addr2.address, 50);
        const addr2Balance = await token.balanceOf(addr2.address);
        expect(addr2Balance).to.equal(50);

      });
      it("Should Decrease the balance on casting the votes", async ()=>{
        await token.transfer(addr1.address, 50);
        const beforeBalance = await token.balanceOf(addr1.address);
        await token.connect(addr1).castVotes(0);
        const afterBalance = await token.balanceOf(addr1.address);

        expect(afterBalance).to.equal(beforeBalance-1);
      })
      it("Should not be able to cast votes, if zero balance", async ()=>{
        await expect(
            token.connect(addr1).castVotes(0)
          ).to.be.revertedWith("Not Enough Balance");
      })
      it("Should throw Require when casting wrong vote", async()=>{
        await expect(token.castVotes(5)).to.be.revertedWith("The Positions Available to vote is from 0 - 4")
      })
    });
  });
});
