const Election = artifacts.require("Election");
const Vote = artifacts.require("Vote");

module.exports = async function(deployer) {
  // Replace 'election1' and 'data1' with your actual values
  await deployer.deploy(Election, 'election1', 'data1');
  await deployer.deploy(Vote);
};