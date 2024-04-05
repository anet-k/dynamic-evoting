const { ethers } = require("hardhat");
console.log(ethers.utils);


const choice = ethers.utils.formatBytes32String("myChoice");
const blindedChoice = ethers.utils.keccak256(choice);

//const choice = "myChoice";
//const blindedChoice = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(choice));

async function main() {
    // Deploy the contracts and measure gas usage
    const Vote = await ethers.getContractFactory("SubmitVote");
    const vote = await Vote.deploy();
    await vote.deployed();
    const voteConstructorReceipt = await vote.deployTransaction.wait();
    console.log(`Gas used by Vote constructor: ${voteConstructorReceipt.gasUsed.toString()}`);

    let totalGasUsed1 = 0;
    let totalGasUsed2 = 0;
    //  Measure gas usage of 10 users submitting their vote
    for (let i = 0; i < 10; i++) {
    let tokenId = i;
    //let tokenId = 1;

    console.log(`Calling submitComittment with blindedChoice=${blindedChoice} and tokenId=${tokenId}`);
    let tx = await vote.submitCommitment(blindedChoice, tokenId);
    let receipt = await tx.wait();
    let gasUsedBySubmitCommitment = receipt.gasUsed.toNumber();

    console.log(`Calling verifyVote with choice=${choice} and tokenId=${tokenId}`);
    let tx2 = await vote.verifyVote(choice, tokenId);
    let receipt2 = await tx2.wait();
    let gasUsedByVerifyVote = receipt2.gasUsed.toNumber();

    let userTotalGasUsed = gasUsedBySubmitCommitment + gasUsedByVerifyVote;
    console.log(`Total gas used by submitComittment and verifyVote: ${totalGasUsed1}`);

    totalGasUsed1 += userTotalGasUsed;
    }
    console.log(`Total gas used by all users for submitComittment and verifyVote: ${totalGasUsed1}`);

    // Measure gas usage of one user submitting their vote
    for (let i = 0; i < 5; i++) {
    let tokenId = i;

    // Now, let's get the user to submit an alteration vote
    console.log(`Calling commitAlteration with blindedChoice=${blindedChoice} and tokenId=${tokenId}`);
    let tx3 = await vote.commitAlteration(blindedChoice, tokenId);
    let receipt3 = await tx3.wait();
    let gasUsedByCommitAlteration = receipt3.gasUsed.toNumber();

    console.log(`Calling verifyAlteration with choice=${choice} and tokenId=${tokenId}`);
    let tx4 = await vote.verifyAlteration(choice, tokenId);
    let receipt4 = await tx4.wait();
    let gasUsedByVerifyAlteration = receipt4.gasUsed.toNumber();

    let totalGasUsedAlteration = gasUsedByCommitAlteration + gasUsedByVerifyAlteration;
    console.log(`Total gas used by commitAlteration and verifyAlteration: ${totalGasUsedAlteration}`);

    totalGasUsed2 += totalGasUsedAlteration;
    }
    console.log(`Total gas used by all users for commitAlteration and verifyAlteration: ${totalGasUsed2}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });