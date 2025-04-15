require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  defaultNetwork: "localhost",
  networks: {
    localhost: {},
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY_1],
    },
  },
  solidity: "0.8.20",
};
