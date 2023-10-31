require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("dotenv").config();
require("hardhat-gas-reporter");

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
    timeout: 10000000000,
  },
  gasReporter: {
    currency: "USD",
    enabled:  process.env.COIN_MARKET_CAP ? true : false,
    gasPriceApi : "B1ENPRQW64QZG2GW8DCU3PWXCE1S33XHK6",
    coinmarketcap: process.env.COIN_MARKET_CAP,
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