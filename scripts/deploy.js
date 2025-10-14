const hre = require("hardhat");

async function main() {
  console.log("Deploying KipuBank contract...");

  const KipuBank = await hre.ethers.getContractFactory("KipuBank");
  const kipuBank = await KipuBank.deploy();

  await kipuBank.waitForDeployment();

  const address = await kipuBank.getAddress();
  console.log(`KipuBank deployed to: ${address}`);
  
  // Display contract info
  const withdrawalLimit = await kipuBank.getWithdrawalLimit();
  console.log(`Withdrawal limit: ${hre.ethers.formatEther(withdrawalLimit)} ETH`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
