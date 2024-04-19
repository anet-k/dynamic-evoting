const { ethers } = require("hardhat");

async function main() {
    const Authorise = await ethers.getContractFactory("Authorise");
    const authorise = await Authorise.deploy();
    await authorise.deployed();

    const accounts = await ethers.getSigners();
    const message = "dummymessage"; // This is a dummy message
    const certificate = ethers.utils.id(message);
    
    let authorise_total = 0;
    let totalGasUsed = ethers.BigNumber.from(0);
    let totalCost = ethers.BigNumber.from(0);

    for (let i = 0; i < 10; i++) {
        const signature = await accounts[i].signMessage(ethers.utils.arrayify(certificate));

        // Convert the signature to the format expected by the contract
        const splitSignature = ethers.utils.splitSignature(signature);
        const signatureBytes32 = ethers.utils.hexZeroPad(splitSignature.r, 32) + ethers.utils.hexZeroPad(splitSignature.s, 32).slice(2) + splitSignature.v.toString(16).padStart(2, '0');
               
        const authorise1_Start = Date.now();

        const tx = await authorise.connect(accounts[i]).requestBallot(certificate, signatureBytes32);
        const receipt = await tx.wait();

        const authorise1_End = Date.now();
        const authorise1_Taken = authorise1_Start - authorise1_End;
        authorise_total += authorise1_Taken;
        console.log(`Time taken to authorise: ${authorise1_Taken} milliseconds`);

        console.log(`Gas used by account ${i}: ${receipt.gasUsed.toString()}`);
        totalGasUsed = totalGasUsed.add(receipt.gasUsed);

        const gasUsed = receipt.gasUsed;
        const gasPrice = await ethers.provider.getGasPrice();
        const cost = gasUsed.mul(gasPrice);
        console.log(`Cost for account ${i}: ${ethers.utils.formatEther(cost.toString())} ether`); 
        totalCost = totalCost.add(cost);
    } 
    console.log(`Total time taken for 10 runs of Authorise: ${authorise_total}`);
    console.log(`Total gas used for 10 runs: ${totalGasUsed.toString()}`);
    console.log(`Total cost for 10 runs: ${ethers.utils.formatEther(totalCost.toString())} ether`);

const Message = "dummymessage";
const Certificate = ethers.utils.id(Message);
const Signature = await accounts[1].signMessage(ethers.utils.arrayify(Certificate));
const SplitSignature = ethers.utils.splitSignature(Signature);
const SignatureBytes32 = ethers.utils.hexZeroPad(SplitSignature.r, 32) + ethers.utils.hexZeroPad(SplitSignature.s, 32).slice(2) + SplitSignature.v.toString(16).padStart(2, '0');
    
console.log("Message:", message);
console.log("Certificate:", certificate);
console.log("Signature Bytes32:", SignatureBytes32);
}   
  main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });