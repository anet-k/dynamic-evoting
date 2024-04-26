/** @type import('hardhat/config').HardhatUserConfig */
require('hardhat-gas-reporter');
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.25"
      },
      {
        version: "0.6.6"
      },
      {
        version: "0.4.24"
      }
    ]
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 21
  }
};
