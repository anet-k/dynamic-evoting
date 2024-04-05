//FROM:! https://web3js.readthedocs.io/en/v1.2.0/web3-eth-contract.html#deploy


const Web3 = require('web3').default;
const fs = require('fs');

// Connect to the network
let web3 = new Web3('http://localhost:8545');

// Read the binary and ABI files
let abi = fs.readFileSync('election_init_sol_Election.abi');
let bin = fs.readFileSync('election_init_sol_Election.bin');

// Deploy the contract
let contract = new web3.eth.Contract(JSON.parse(abi));
contract.deploy({
    data: '0x' + bin,
    arguments: ['election0', 'data0'] // constructor arguments
}).send({
    from: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
    gas: 1500000,
    gasPrice: '30000000000000'
}, function(error, transactionHash) { /* ... */ })
.on('receipt', function(receipt) {
    console.log(receipt.contractAddress) // contains the new contract address
});