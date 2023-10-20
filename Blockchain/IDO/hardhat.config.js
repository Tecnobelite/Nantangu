require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  mocha: {
    timeout: 100000000,
  },
  gasReporter: {
    currency: "USD",
    gasPrice: 5,
    enabled: false,
    // coinmarketcap: process.env.COINMARTKETCAP_API,
  },
  etherscan: {
    apiKey: {

    },
  },
  networks: {
    hardhat: {
      forking: {
        url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      },
    },

    polygon_testnet: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 80001,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },

    bsc_testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },

    ethereum_mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 1,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },

    polygon_mainnet: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 137,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },

    bsc_mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },
  },
};