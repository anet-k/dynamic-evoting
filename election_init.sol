pragma solidity >=0.4.22 <0.7.0;

//each Election contract means a new election
contract Election {
    //create genesis block and put it as a first block on the blockchain
    struct Block {
        uint index;     //index of the block - 0 for genesis block
        string electionId;  //identifier of the current election
        string previousHash;    //integrity, and immutability
        string hash;    //hash of the block data - for integrity and immutability
        string data;   //information about the election (name, candidates, rules, etc.)
        uint timestamp;
    }

    //array of blocks
    Block[] public blockchain;

    //constructor
    constructor(string memory _electionId, string memory _data) public { //using _electionId instead of electionId because _electionId is a local variable
        //create the genesis block
        string memory previousHash = "0"; //since there's no previous block
        uint timestamp = block.timestamp; //current time
        string memory hash = generateHash(0, previousHash, data, timestamp);


        Block memory genesisBlock = Block(0, hash, previousHash, electionId, data, timestamp);
        blockchain.push(genesisBlock);    
    }
    
}