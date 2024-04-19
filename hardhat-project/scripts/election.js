const { ethers } = require("hardhat");

async function main() {

    const electionStart = Date.now();

    // Deploy the Election contract
    const Election = await ethers.getContractFactory("Election");
    const election = await Election.deploy("0", "data"); // Add constructor arguments if needed
    await election.deployed();
    //console.log(`Election contract deployed at address: ${election.address}`);

    const electionEnd = Date.now();
    const electionTaken = electionEnd - electionStart;
    console.log(`Time taken to deploy the contract: ${electionTaken} milliseconds`);


    // Get the receipt of the deployment transaction
    const receipt = await election.deployTransaction.wait();
    // Get the gas used by the deployment transaction
    const gasUsed = receipt.gasUsed;
    // Get the current gas price from the provider
    const gasPrice = await ethers.provider.getGasPrice();
    // Calculate the total cost
    const totalCost = gasPrice.mul(gasUsed);

    console.log(`Gas used by Election contract deployment/execution: ${gasUsed.toString()}`);
    console.log(`Total cost of Election contract deployment/execution: ${ethers.utils.formatEther(totalCost)} ether`);

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });