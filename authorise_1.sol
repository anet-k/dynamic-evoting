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

 //SPDX-License-Identifier: UNLICENSEd

pragma solidity >=0.8.0 <0.9.0;
//import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/ChainlinkFulfillmentInterface.sol";
import ".deps/npm/@chainlink/contracts/src//v0.8/ChainlinkClient.sol";
import "mock_verifier.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Authorise is ChainlinkClient{

    MockVerifier public verifier;

    struct Token{
        uint256 tokenId;
        address voter; //not sure, since de-linkability
    }

    //user sends X.509 certificate to the smart contract
    bytes32 private certificate;
    bytes32 private publicKey;

    //Chainlink parameters
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    uint256[] public eligibleVoters;
    mapping(address => bytes32) public signatures;

    event RequestSignature(address indexed voter, string message);
    event InvalidSignature(address indexed voter, string message);
    event VoterAuthenticated(address indexed voter, uint256 tokenId);

    constructor() {
        verifier = new MockVerifier(); //FIX - finish setting up the verifier
            //deploy mock_verifier on testnet
            //external adapter that calls verifiyCertificate (from mock_verifier.sol) and returns the public key
            //add the external adapter to chainlink node
            //specify jobID of that external adapter in requestBallot

        //_setPublicChainlinkToken(); 
        _setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        //oracle = _oracle;
        //jobId = _jobId;
        //fee = _fee;
    }

    //ref: https://ethereum.stackexchange.com/questions/126585/how-to-build-chainlink-request-so-that-the-response-will-be-sent-to-another-cont
    function requestBallot(bytes32 _certificate) public {
        certificate = _certificate;
        Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        //req.add("certificate", certificate);   //IDK
        //req.add("get", data);
        //req.add("path", "data");
        _sendChainlinkRequestTo(oracle, req, fee);

    }

    //function that Chainlink callls once it has the callback = the response
    function fulfill (bytes32 _requestId, bytes32 _publicKey) public recordChainlinkFulfillment(_requestId){
        publicKey = _publicKey;
        //atuhenticating the certificate first may be costly, and requires signing anyway. 


        //request signature from user
        requestSignature(); //trigger requestSignature
    }

    //get user to sign with their private key
    function requestSignature() public {
        //send message to user to sign with their private key
        emit RequestSignature(msg.sender, "Please sign with your private key");
    }


    //user uses this function to submit their private key, and smart contract then processes it
    function processSignature(bytes32 _userSignature) public {
        //add pair address and signature to the list of signatures
        signatures[msg.sender] = _userSignature;
        //verify signature
        require(verifySignature(_userSignature), "Invalid signature");
        //if signature is valid, mint NFT
        mintNFT(msg.sender);
        //if signature is invalid, send message to user that signature is invalid
        emit InvalidSignature(msg.sender, "The signature is invalid");
    }

    //ref: https://www.web3.university/article/how-to-verify-a-signed-message-in-solidity
    //ref: https://solidity-by-example.org/signature/
    function verifySignature(bytes32 _signature) public view returns (bool) {
        //verify signature
        bytes32 messageHash = keccak256(abi.encodePacked(_signature));

        //split signature into r, s, v
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);

        //address who signed the message
        address signer = ecrecover(messageHash, v, r, s);

        //compare recoverAddress with the sender
        bool isSender = (signer == msg.sender);

        //compare expected sig with the real sig
        //FIX
        bool isSignature = (keccak256(abi.encodePacked(signatures[msg.sender])) == keccak256(abi.encodePacked(_signature)));

        return isSender && isSignature;

    }

    //helper function to verifySignature
    function splitSignature (bytes32 sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function mintNFT(address _voter) public {
        //mint NFT

        //generate NFT token, by creating new instance of VoterToken contract
        VoterToken voterToken = new VoterToken();
        //calling registerVoter from VoterToken contract
        uint256 tokenId = voterToken.registerVoter(_voter);

        //add token to the list of eligible voters
        eligibleVoters.push(tokenId);

        emit VoterAuthenticated(msg.sender, tokenId);



    }

}


contract VoterToken is ERC721 {
    uint256 public tokenCounter;
    uint256 public nextTokenId = 0;

    event TokenMinted(address indexed voter, uint256 tokenId);

    constructor() ERC721("VoterToken", "VOTER") {
        tokenCounter = 0;
    }

    //creates NFT for specified voter
    function registerVoter(address voter) public returns (uint256) {
        uint256 tokenId = nextTokenId;
        _mint(voter, tokenId); //ERC721 function that creates the token and assigns it to the user(voter)
        emit TokenMinted(voter, tokenId); //create a record of a new token created
        nextTokenId++;
        return tokenId;
    }


}
