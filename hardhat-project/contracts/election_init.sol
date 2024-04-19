pragma solidity ^0.8.25;

// SPDX-License-Identifier: UNLICENSED

 /**
   * @title Election
   * @dev ContractDescription
   * @custom:dev-run-script election_init.sol
   */

//2. each Election contract means a new election
contract Election {

    struct Block {
        uint index;     //index of the block - 0 for genesis block
        string electionId;  //identifier of the current election
        bytes32 hash;    //hash of the block data - for integrity and immutability
        bytes32 previousHash; //hash of the previous block
        string data;   //information about the election (name, candidates, rules, etc.)
        uint timestamp;
    }

    //array of blocks
    Block[] public blockchain;

    function generateHash(uint index, bytes32 previousHash, string memory data, uint timestamp) private pure returns(bytes32) { 
        //keep bytes32 to be more gas efficient
        return keccak256(abi.encodePacked(index, previousHash, data, timestamp));
    }

    //constructor
    constructor(string memory _electionId, string memory _data) { //using _electionId instead of electionId because _electionId is a local variable
        //2.1 create genesis block and put it as a first block on the blockchain
        bytes32 previousHash = 0x0; //since there's no previous block
        uint timestamp = block.timestamp; //current time
        bytes32 hash = generateHash(0, previousHash, _data, timestamp);


        Block memory genesisBlock = Block(0, _electionId, hash, previousHash, _data, timestamp);
        blockchain.push(genesisBlock); 
    }
}