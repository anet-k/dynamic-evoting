const { ethers } = require("hardhat");

const choice = ethers.utils.formatBytes32String("myChoice");
const blindedChoice = ethers.utils.keccak256(choice);

async function main() {

    // Deploy the contracts and measure gas usage
    const Vote = await ethers.getContractFactory("SubmitVote");
    const vote = await Vote.deploy();
    await vote.deployed();
    //const voteConstructorReceipt = await vote.deployTransaction.wait();
    //console.log(`Gas used by Vote constructor: ${voteConstructorReceipt.gasUsed.toString()}`);

    let totalTimeTaken10Vote = 0;
    let totalGasVote = ethers.BigNumber.from(0); 
    let totalCostVote = ethers.BigNumber.from(0);

    // Measure gas usage of 10 users submitting their vote
    for (let i = 0; i < 10; i++) {
    let tokenId = i;

    // Start the timer
    const submit1_Start = Date.now();

    let tx = await vote.submitCommitment(blindedChoice, tokenId);
    let receipt = await tx.wait();
    let gasUsedBySubmitCommitment = receipt.gasUsed;

    let tx2 = await vote.verifyVote(choice, tokenId);
    let receipt2 = await tx2.wait();
    let gasUsedByVerifyVote = receipt2.gasUsed;

    // End the timer and calculate the difference
    const endTimeSubmit1 = Date.now();
    const timeTakenSubmit1 = endTimeSubmit1 - submit1_Start;
    totalTimeTaken10Vote += timeTakenSubmit1;
    console.log(`Time taken to submit a vote for 1 user${i}: ${timeTakenSubmit1} milliseconds`);


    const gasPrice = await ethers.provider.getGasPrice();
    const costSubmitCommitment = gasPrice.mul(gasUsedBySubmitCommitment);
    const costVerifyVote = gasPrice.mul(gasUsedByVerifyVote);

    let vote1_total = gasUsedBySubmitCommitment.add(gasUsedByVerifyVote);
    let vote1_Cost = costSubmitCommitment.add(costVerifyVote);

    console.log(`Gas used to vote once by user ${i}: ${vote1_total.toString()}`);
    console.log(`Cost of voting once by user ${i}: ${ethers.utils.formatEther(vote1_Cost.toString())} ether`);
    
    totalGasVote = totalGasVote.add(vote1_total);
    totalCostVote = totalCostVote.add(vote1_Cost);
    }

    console.log(`Gas used for 10 users voting: ${totalGasVote.toString()}`);
    console.log(`Cost for 10 users voting: ${ethers.utils.formatEther(totalCostVote.toString())} ether`);

let totalTimeTaken5Alter = 0;
let totalGasAlter = ethers.BigNumber.from(0); 
let totalCostAlter = ethers.BigNumber.from(0);

    // Measure gas usage of 5 users submitting their alteration vote
    for (let i = 0; i < 5; i++) {
        let tokenId = i;
    
        // Start the timer
        const alter1_Start = Date.now();

        // Now, let's get the user to submit an alteration vote
        let tx3 = await vote.commitAlteration(blindedChoice, tokenId);
        let receipt3 = await tx3.wait();
        let gasUsedByCommitAlteration = receipt3.gasUsed;

        let tx4 = await vote.verifyAlteration(choice, tokenId);
        let receipt4 = await tx4.wait();
        let gasUsedByVerifyAlteration = receipt4.gasUsed;

        // End the timer and calculate the difference
        const endTimeAlter1 = Date.now();
        const timeTakenAlter1 = endTimeAlter1 - alter1_Start;
        totalTimeTaken5Alter += timeTakenAlter1;
        console.log(`Time taken to alter a vote for 1 user${i}: ${timeTakenAlter1} milliseconds`);

        const gasPrice = await ethers.provider.getGasPrice();
        const costCommitAlteration = gasPrice.mul(gasUsedByCommitAlteration);
        const costVerifyAlteration = gasPrice.mul(gasUsedByVerifyAlteration);
    
        let alter1_total = gasUsedByCommitAlteration.add(gasUsedByVerifyAlteration);
        let alter1_Cost = costCommitAlteration.add(costVerifyAlteration);

        console.log(`Gas used to vote once by user ${i}: ${alter1_total.toString()}`);
        console.log(`Cost of voting once by user ${i}: ${ethers.utils.formatEther(alter1_Cost.toString())} ether`);
    
        totalGasAlter = totalGasAlter.add(alter1_total);
        totalCostAlter = totalCostAlter.add(alter1_Cost);
        }
    console.log(`Gas used for 5 users altering: ${totalGasAlter.toString()}`);
    console.log(`Cost for 5 users altering: ${ethers.utils.formatEther(totalCostAlter.toString())} ether`);
    
    }

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });