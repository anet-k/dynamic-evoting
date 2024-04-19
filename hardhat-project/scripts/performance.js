const { ethers } = require("hardhat");

const choice = ethers.utils.formatBytes32String("myChoice");
const blindedChoice = ethers.utils.keccak256(choice);

let totalTime = 0;
let totalGasUsed = ethers.BigNumber.from(0);
let totalCost = ethers.BigNumber.from(0);

async function main() {
    // Deploy the Election contract
    const electionStart = Date.now();
    const Election = await ethers.getContractFactory("Election");
    const election = await Election.deploy("0", "data"); // Add constructor arguments if needed
    await election.deployed();

    const electionEnd = Date.now();
    const electionTaken = electionEnd - electionStart;
    totalTime += electionTaken;

    const receipt = await election.deployTransaction.wait();
    const gasUsedE = receipt.gasUsed;
    const gasPrice = await ethers.provider.getGasPrice();
    const totalCostInit = gasPrice.mul(gasUsedE);

    totalGasUsed = totalGasUsed.add(gasUsedE);
    totalCost = totalCost.add(totalCostInit);


    // Deploy the Authorise contrct
    const AuthoriseStart = Date.now();
    const Authorise = await ethers.getContractFactory("Authorise");
    const authorise = await Authorise.deploy();
    await authorise.deployed();
    const AuthoriseEnd = Date.now();
    let AuthoriseTaken = AuthoriseEnd - AuthoriseStart;
    console.log(`Time taken to deploy authorise contract: ${AuthoriseTaken} milliseconds`);


    const accounts = await ethers.getSigners();
    const message = "dummymessage"; // This is a dummy message
    const certificate = ethers.utils.id(message);
    
    let authorise_total = 0;
    let totalGasAuth = ethers.BigNumber.from(0);
    let totalCostAuth = ethers.BigNumber.from(0);

    for (let i = 0; i < 10; i++) {
        const signature = await accounts[i].signMessage(ethers.utils.arrayify(certificate));

        // Convert the signature to the format expected by the contract
        const splitSignature = ethers.utils.splitSignature(signature);
        const signatureBytes32 = ethers.utils.hexZeroPad(splitSignature.r, 32) + ethers.utils.hexZeroPad(splitSignature.s, 32).slice(2) + splitSignature.v.toString(16).padStart(2, '0');
               
        const authorise1_Start = Date.now();

        const tx = await authorise.connect(accounts[i]).requestBallot(certificate, signatureBytes32);
        const receipt = await tx.wait();

        const authorise1_End = Date.now();
        const authorise1_Taken = authorise1_End - authorise1_Start;
        authorise_total += authorise1_Taken;


        totalGasAuth = totalGasAuth.add(receipt.gasUsed);

        const gasUsedA = receipt.gasUsed;
        const gasPrice = await ethers.provider.getGasPrice();
        const cost = gasUsedA.mul(gasPrice);
        totalCostAuth = totalCostAuth.add(cost);
    } 

    totalTime += authorise_total;
    totalGasUsed = totalGasUsed.add(totalGasAuth);
    totalCost = totalCost.add(totalCostAuth);

    // Deploy the SubmitVote contract
    const Vote = await ethers.getContractFactory("SubmitVote");
    const vote = await Vote.deploy();
    await vote.deployed();
    
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

    const gasPrice = await ethers.provider.getGasPrice();
    const costSubmitCommitment = gasPrice.mul(gasUsedBySubmitCommitment);
    const costVerifyVote = gasPrice.mul(gasUsedByVerifyVote);

    let vote1_total = gasUsedBySubmitCommitment.add(gasUsedByVerifyVote);
    let vote1_Cost = costSubmitCommitment.add(costVerifyVote);

    totalGasVote = totalGasVote.add(vote1_total);
    totalCostVote = totalCostVote.add(vote1_Cost);
    }
    totalTime += totalTimeTaken10Vote;
    totalGasUsed = totalGasUsed.add(totalGasVote);
    totalCost = totalCost.add(totalCostVote);
   
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

        const gasPrice = await ethers.provider.getGasPrice();
        const costCommitAlteration = gasPrice.mul(gasUsedByCommitAlteration);
        const costVerifyAlteration = gasPrice.mul(gasUsedByVerifyAlteration);
    
        let alter1_total = gasUsedByCommitAlteration.add(gasUsedByVerifyAlteration);
        let alter1_Cost = costCommitAlteration.add(costVerifyAlteration);
    
        totalGasAlter = totalGasAlter.add(alter1_total);
        totalCostAlter = totalCostAlter.add(alter1_Cost);
        }
        totalTime += totalTimeTaken5Alter;
        totalGasUsed += totalGasAlter;
        totalCost += totalCostAlter;

        console.log(`Total time taken for all contracts: ${totalTime}`);
        console.log(`Total gas used for all contracts: ${totalGasUsed.toString()}`);
        console.log(`Total cost for all contracts: ${ethers.utils.formatEther(totalCost.toString())} ether`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });