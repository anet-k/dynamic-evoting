//steps:
//3.1. smart contract receives transaction from the voter (requesting a ballot)
//4.1. smart contract requests certificate (X.509) to verify 
//4.1.1 send message to request a certificate to the owner of the transaction in requestBallot() 
//4.1.2 smart contract receives certificate as input, and save it in a variable 
//4.1.3 smart contract runs oracle for verification of the certificate. 
//4.1.4 smart contract reads message from the oracle, requesting data(public key) from the certificate 
//4.1.4.1 if certificate is valid, smart contract uses the data and asks user to sign with their private key 
//4.1.4.2 if certificate is invalid, smart contract sends a message to the user that the certificate is invalid 
//4.1.5 smart contract receives message from the user, and checks if the real signature is matching the expected signature. 
//4.1.5.1 if the user is authenticated, smart contract generates a unique NFT token and adds it to the ballot, and sends this ballot to the user 
//4.1.5.2 if the user is not authenticated, smart contract sends a message to the user that the access is unauthorised 
//4.1.6 smart contract saves the token in the list of eligible voters



pragma solidity >=0.8.0 <0.9.0;

import "https://github.com/smartcontractkit/chainlink/blob/develop/evm-contracts/src/v0.6/ChainlinkClient.sol"; // Import ChainlinkClient to interact with Chainlink Oracles
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract Authorise is ChainlinkClient{

    struct Voter {
        string certificate;
        string signature;
        bool authorised;
        bool voted;
        string token;
    }

    struct Certificate {
        string data;
        string publicKey;
        //string Signature;
    }

    struct Ballot {
        uint token;
        bool used;
        //string data;
    } 

    mapping(address => Certificate) public certificates;
    mapping(address => Ballot) public ballots;
    mapping(address => Voter) public voters;



   // Define Chainlink parameters
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    string public extractData;

    constructor(address _oracle, string memory _jobId, uint256 _fee) public {
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709); // Set LINK token address //HOW
        oracle = _oracle;
        jobId = stringToBytes32(_jobId);
        fee = _fee;
    }
   
    //4.1. smart contract requests certificate (X.509) to verify
    event CertificateRequested(address owner, string message);
    function requestCertificate() public {
        //4.1.1 send message to request a certificate to the owner of the transaction in requestBallot()
        emit CertificateRequested(msg.sender, "Please provide certificate for authentication");  //off-chain service listens to the event and sends message to the transaction owner
        //4.1.3 smart contract runs oracle for verification of the certificate. 
            //oracle  - verifier has oracle running locally (not running on the blockchain) oracle a sw on a cloud machine - and function only awaits a callback 
            Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.verificationResult.selector);
            req.add("certificate", certificates[msg.sender].data); //add certificate to the request
            sendChainlinkRequestTo(oracle, req, fee); //send request to the oracle
    }
  
    //3.1. smart contract receives transaction from the voter (requesting a ballot)
    function requestBallot() public returns (bytes32) {

        //triggers a request for a certificate from the voter
        requestCertificate();
    }
    //4.1.2 smart contract receives certificate as input, and save it in a variable

    function submitCertificate (string memory _certificate) public {
        certificates[msg.sender].data = _certificate; //_certificate is variable holding the certificate
            
}
    //4.1.4 smart contract reads message from the oracle, requesting data(public key) from the certificate
    //function for oracle to communicate with smart contract

    //function is called by the Chainlink node when it has validated the certificate
    function verificationResult (bool _requestID, bool _result, string memory data) public {
        reqiure(msg.sender == oracle, "Only oracle can call this function");
        address voter = msg.sender;
        voters[voter].authorised = _result;
        extractData = data;

        
        //4.1.4.1 if certificate is valid, smart contract uses the data and asks user to sign with their private key
        if (_result == true) {
            //ask user to sign with their private key
            emit RequestSignature(voter, "Please sign with your private key");

        }
        //4.1.4.2 if certificate is invalid, smart contract sends a message to the user that the certificate is invalid
        else {
            //send message to the user that the certificate is invalid
            emit InvalidCertificate(voter, "The certificate is invalid");

        }

    }

    function submitSignature(bytes memory signature) public {
        //verify sig
        require(verifySignature(extractData, signature), "Invalid signature");
    }

    //FIX - add proper signature check scheme
    function verifySignature() {}
    }

}

contract VoterToken is ERC721 {
    uint256 public tokenCounter;
    uint256 public nextTokenId = 0;

    constructor() ERC721("VoterToken", "VOTER") {
        tokenCounter = 0;
    }

    //creates NFT for specified voter
    function registerVoter(address voter) public returns (uint256) {
        uint256 tokenId = nextTokenId;
        _mint(voter, tokenId);
        nextTokenId++;
        return tokenId;
    }


    //function to verify signature
    function verifySignature(string memory data, bytes memory signature) public pure returns (bool) {
        //verify signature: compare expected signature with the real signature

        
    }
}






