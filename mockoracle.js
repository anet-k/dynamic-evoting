const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Authorise", () => {
  let myContract, mockOracle, linkToken;
  const jobId = "4c7b7ffb66b344fbaa64995af81e355a";

  beforeEach(async () => {
    const LinkToken = await ethers.getContractFactory("VoterToken");
    linkToken = await LinkToken.deploy();
    const MockOracle = await ethers.getContractFactory("MockOracle");
    mockOracle = await MockOracle.deploy(linkToken.address);
    const MyContract = await ethers.getContractFactory("Authorise");
    myContract = await MyContract.deploy(linkToken.address, mockOracle.address, jobId);
  });

  it("should create a Chainlink request", async () => {
    // Arrange
    const payment = "1000000000000000000"; // 1 LINK
    await linkToken.transfer(myContract.address, payment);

    // Act
    const tx = await myContract.requestData("Hello, Chainlink!", payment);

    // Assert
    const receipt = await tx.wait();
    const requestId = receipt.events[0].topics[1];
    expect(await mockOracle.hasRequest(requestId)).to.be.true;
  });
});