const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("KipuBank", function () {
  // Fixture to deploy the contract
  async function deployKipuBankFixture() {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const KipuBank = await ethers.getContractFactory("KipuBank");
    const kipuBank = await KipuBank.deploy();
    await kipuBank.waitForDeployment();

    return { kipuBank, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the correct withdrawal limit", async function () {
      const { kipuBank } = await loadFixture(deployKipuBankFixture);
      expect(await kipuBank.getWithdrawalLimit()).to.equal(ethers.parseEther("1"));
    });

    it("Should have zero balance for new users", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      expect(await kipuBank.getBalance(addr1.address)).to.equal(0);
    });
  });

  describe("Deposit", function () {
    it("Should allow users to deposit ETH", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("0.5");

      await expect(kipuBank.connect(addr1).deposit({ value: depositAmount }))
        .to.emit(kipuBank, "Deposit")
        .withArgs(addr1.address, depositAmount, depositAmount);

      expect(await kipuBank.getBalance(addr1.address)).to.equal(depositAmount);
    });

    it("Should accumulate multiple deposits", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount1 = ethers.parseEther("0.3");
      const depositAmount2 = ethers.parseEther("0.2");

      await kipuBank.connect(addr1).deposit({ value: depositAmount1 });
      await kipuBank.connect(addr1).deposit({ value: depositAmount2 });

      const expectedBalance = depositAmount1 + depositAmount2;
      expect(await kipuBank.getBalance(addr1.address)).to.equal(expectedBalance);
    });

    it("Should revert on zero deposit", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);

      await expect(
        kipuBank.connect(addr1).deposit({ value: 0 })
      ).to.be.revertedWithCustomError(kipuBank, "ZeroDeposit");
    });

    it("Should allow getMyBalance to work correctly after deposit", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("0.5");

      await kipuBank.connect(addr1).deposit({ value: depositAmount });
      expect(await kipuBank.connect(addr1).getMyBalance()).to.equal(depositAmount);
    });
  });

  describe("Withdrawal", function () {
    it("Should allow users to withdraw ETH", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("0.8");
      const withdrawAmount = ethers.parseEther("0.3");

      await kipuBank.connect(addr1).deposit({ value: depositAmount });
      
      const initialBalance = await ethers.provider.getBalance(addr1.address);
      
      const tx = await kipuBank.connect(addr1).withdraw(withdrawAmount);
      const receipt = await tx.wait();
      const gasUsed = receipt.gasUsed * receipt.gasPrice;

      const finalBalance = await ethers.provider.getBalance(addr1.address);
      const contractBalance = await kipuBank.getBalance(addr1.address);

      expect(contractBalance).to.equal(depositAmount - withdrawAmount);
      expect(finalBalance).to.equal(initialBalance + withdrawAmount - gasUsed);
    });

    it("Should emit Withdrawal event", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("0.8");
      const withdrawAmount = ethers.parseEther("0.3");

      await kipuBank.connect(addr1).deposit({ value: depositAmount });

      await expect(kipuBank.connect(addr1).withdraw(withdrawAmount))
        .to.emit(kipuBank, "Withdrawal")
        .withArgs(addr1.address, withdrawAmount, depositAmount - withdrawAmount);
    });

    it("Should revert on zero withdrawal", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      
      await kipuBank.connect(addr1).deposit({ value: ethers.parseEther("0.5") });

      await expect(
        kipuBank.connect(addr1).withdraw(0)
      ).to.be.revertedWithCustomError(kipuBank, "ZeroWithdrawal");
    });

    it("Should revert when withdrawal exceeds balance", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      
      await kipuBank.connect(addr1).deposit({ value: ethers.parseEther("0.5") });

      await expect(
        kipuBank.connect(addr1).withdraw(ethers.parseEther("0.6"))
      ).to.be.revertedWithCustomError(kipuBank, "InsufficientBalance");
    });

    it("Should revert when withdrawal exceeds limit", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      
      await kipuBank.connect(addr1).deposit({ value: ethers.parseEther("2") });

      await expect(
        kipuBank.connect(addr1).withdraw(ethers.parseEther("1.1"))
      ).to.be.revertedWithCustomError(kipuBank, "WithdrawalLimitExceeded");
    });

    it("Should allow withdrawal up to the limit", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("2");
      const withdrawAmount = ethers.parseEther("1"); // Exactly the limit

      await kipuBank.connect(addr1).deposit({ value: depositAmount });
      await kipuBank.connect(addr1).withdraw(withdrawAmount);

      expect(await kipuBank.getBalance(addr1.address)).to.equal(
        depositAmount - withdrawAmount
      );
    });

    it("Should allow multiple withdrawals within limit", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("2");
      const withdrawAmount1 = ethers.parseEther("0.5");
      const withdrawAmount2 = ethers.parseEther("0.3");

      await kipuBank.connect(addr1).deposit({ value: depositAmount });
      await kipuBank.connect(addr1).withdraw(withdrawAmount1);
      await kipuBank.connect(addr1).withdraw(withdrawAmount2);

      expect(await kipuBank.getBalance(addr1.address)).to.equal(
        depositAmount - withdrawAmount1 - withdrawAmount2
      );
    });
  });

  describe("Balance Queries", function () {
    it("Should return correct balance for getBalance", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("0.5");

      await kipuBank.connect(addr1).deposit({ value: depositAmount });
      expect(await kipuBank.getBalance(addr1.address)).to.equal(depositAmount);
    });

    it("Should return correct balance for getMyBalance", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      const depositAmount = ethers.parseEther("0.5");

      await kipuBank.connect(addr1).deposit({ value: depositAmount });
      expect(await kipuBank.connect(addr1).getMyBalance()).to.equal(depositAmount);
    });

    it("Should return zero balance for users who never deposited", async function () {
      const { kipuBank, addr1 } = await loadFixture(deployKipuBankFixture);
      
      expect(await kipuBank.getBalance(addr1.address)).to.equal(0);
      expect(await kipuBank.connect(addr1).getMyBalance()).to.equal(0);
    });
  });

  describe("Multiple Users", function () {
    it("Should maintain separate balances for different users", async function () {
      const { kipuBank, addr1, addr2 } = await loadFixture(deployKipuBankFixture);
      const deposit1 = ethers.parseEther("0.5");
      const deposit2 = ethers.parseEther("0.3");

      await kipuBank.connect(addr1).deposit({ value: deposit1 });
      await kipuBank.connect(addr2).deposit({ value: deposit2 });

      expect(await kipuBank.getBalance(addr1.address)).to.equal(deposit1);
      expect(await kipuBank.getBalance(addr2.address)).to.equal(deposit2);
    });

    it("Should not affect other users' balances on withdrawal", async function () {
      const { kipuBank, addr1, addr2 } = await loadFixture(deployKipuBankFixture);
      const deposit1 = ethers.parseEther("0.5");
      const deposit2 = ethers.parseEther("0.3");
      const withdraw1 = ethers.parseEther("0.2");

      await kipuBank.connect(addr1).deposit({ value: deposit1 });
      await kipuBank.connect(addr2).deposit({ value: deposit2 });
      await kipuBank.connect(addr1).withdraw(withdraw1);

      expect(await kipuBank.getBalance(addr1.address)).to.equal(deposit1 - withdraw1);
      expect(await kipuBank.getBalance(addr2.address)).to.equal(deposit2);
    });
  });
});
