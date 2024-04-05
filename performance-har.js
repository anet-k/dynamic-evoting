const { ethers } = require("hardhat");

const choice = "myChoice";
const blindedChoice = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(choice));


async function main() {
    // Deploy the contracts and measure gas usage
    const ElectionInit = await ethers.getContractFactory("Election");
    const electionInit = await ElectionInit.deploy("election1", "{\"name\": \"Presidential Election 2024\"}");
    await electionInit.deployed();
    const constructorReceipt = await electionInit.deployTransaction.wait();
    console.log(`Gas used by ElectionInit constructor: ${constructorReceipt.gasUsed.toString()}`);

    const Vote = await ethers.getContractFactory("SubmitVote");
    const vote = await Vote.deploy();
    await vote.deployed();
    const voteConstructorReceipt = await vote.deployTransaction.wait();
    console.log(`Gas used by Vote constructor: ${voteConstructorReceipt.gasUsed.toString()}`);

    // Measure gas usage of 10 voters submitting their votes
    for (let i = 0; i < 10; i++) {
        let tx = await vote.submitComittment(blindedChoice, i);
        let receipt = await tx.wait();
        console.log(`Gas used by submitComittment: ${receipt.gasUsed.toString()}`);

        tx = await vote.verifyVote(choice, i);
        receipt = await tx.wait();
        console.log(`Gas used by verifyVote: ${receipt.gasUsed.toString()}`);
    }

   // Measure gas usage of 5 voters submitting alteration votes
for (let i = 0; i < 5; i++) {
    let tx = await vote.requestAlteration(choice, i);
    let receipt = await tx.wait();
    console.log(`Gas used by requestAlteration: ${receipt.gasUsed.toString()}`);

    tx = await vote.submitComittment(blindedChoice, i);
    receipt = await tx.wait();
    console.log(`Gas used by submitComittment: ${receipt.gasUsed.toString()}`);

    tx = await vote.verifyAlteration(choice, i);
    receipt = await tx.wait();
    console.log(`Gas used by verifyAlteration: ${receipt.gasUsed.toString()}`);
}
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });