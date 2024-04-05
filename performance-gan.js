const ElectionInit = artifacts.require("Election");
const Vote = artifacts.require("SubmitVote");
const ethers = require("ethers");
const choice = "myChoice";
const blindedChoice = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(choice));
const nft = "0x";

module.exports = async function(callback) {
    try {
        // Deploy the contracts and measure gas usage
        const electionInit = await ElectionInit.new("election1", "{\"name\": \"Presidential Election 2024\"}");
        const vote = await Vote.new();

        // Measure gas usage of 10 voters submitting their votes
        for (let i = 0; i < 10; i++) {
            let tx = await vote.submitComittment(blindedChoice, i);
            console.log(`Gas used by submitComittment: ${tx.receipt.gasUsed}`);

            tx = await vote.verifyVote(choice, i);
            console.log(`Gas used by verifyVote: ${tx.receipt.gasUsed}`);
        }

        // Measure gas usage of 5 voters submitting alteration votes
        for (let i = 0; i < 5; i++) {
            let tx = await vote.requestAlteration(choice, i);
            console.log(`Gas used by requestAlteration: ${tx.receipt.gasUsed}`);

            tx = await vote.submitComittment(blindedChoice, i);
            console.log(`Gas used by submitComittment: ${tx.receipt.gasUsed}`);

            tx = await vote.verifyAlteration(choice, i);
            console.log(`Gas used by verifyAlteration: ${tx.receipt.gasUsed}`);
        }

        callback();
    } catch (error) {
        console.error(error);
        callback(error);
    }
};