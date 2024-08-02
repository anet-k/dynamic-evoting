# Dynamic E-Voting System

This repository contains the source code and documentation for the Dynamic E-Voting System, a blockchain-based electronic voting framework that enables continuous voter engagement throughout a government's tenure.

## Overview

The Dynamic E-Voting System is designed to address the limitations of traditional fixed-term elections by allowing voters to modify their votes at any time, potentially enhancing government accountability beyond initial elections. This system leverages blockchain technology to provide a secure, transparent, and flexible voting platform.

## Repository Structure

```
/
├── hardhat-project/
│   ├── artifacts/
│   ├── build/
│   ├── cache/
│   ├── contracts/
│   ├── node_modules/
│   ├── scripts/
│   ├── test/
│   ├── .DS_Store
│   ├── LICENSE
│   ├── hardhat.config.js
│   ├── helper-functions.js
│   ├── helper-hardhat-config.js
│   └── package.json
├── node_modules/
├── .DS_Store
├── README.md
├── authorise_1.sol
├── authorise_chainlink.sol
├── election_init.sol
├── mock_chainlink.sol
├── mock_oracle.sol
├── mockoracle.js
└── vote_2.sol
```

## Key Components

- `hardhat-project/`: Contains the main Hardhat project structure
  - `contracts/`: Smart contract source code
  - `scripts/`: Deployment and interaction scripts
  - `test/`: Test scripts for smart contracts
- `authorise_1.sol`, `authorise_chainlink.sol`: Authorization contracts
- `election_init.sol`: Election initialization contract
- `vote_2.sol`: Voting contract
- `mock_chainlink.sol`, `mock_oracle.sol`, `mockoracle.js`: Mock implementations for testing

## Getting Started

### Prerequisites

- Node.js (v14.0.0 or later)
- Hardhat
- MetaMask (for interacting with the DApp on a live network)

### Installation

1. Clone the repository:
   ```
   git clone [repository-url]
   ```

2. Install dependencies:
   ```
   cd hardhat-project
   npm install
   ```

3. Compile smart contracts:
   ```
   npx hardhat compile
   ```

4. Run tests:
   ```
   npx hardhat test
   ```

## Smart Contracts

The system comprises several smart contracts:

- `authorise_1.sol` and `authorise_chainlink.sol`: Handle voter authorization
- `election_init.sol`: Manages election initialization
- `vote_2.sol`: Implements the voting logic

## Testing

Test files are located in the `hardhat-project/test/` directory. To run the tests:

```
cd hardhat-project
npx hardhat test
```

## Deployment

Deployment scripts are located in the `hardhat-project/scripts/` directory. To deploy:

```
cd hardhat-project
npx hardhat run scripts/deploy.js --network [network-name]
```

## Contributing

We welcome contributions to the Dynamic E-Voting System. Please feel free to submit issues and pull requests.

## License

This project is open source and available under the license specified in the LICENSE file in the hardhat-project directory.

## Contact

For questions or feedback, please open an issue in this repository or contact the repository owner.
