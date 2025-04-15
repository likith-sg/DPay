const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contract with account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const DPay = await hre.ethers.getContractFactory("DPay");
  const dpay = await DPay.deploy();
  await dpay.deployed();

  console.log("DPay deployed to:", dpay.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment error:", error);
    process.exit(1);
  });
