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

pragma solidity ^0.8.25;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";


contract MockOracle {
    bytes32 public publicKey = "PublicKey";

    function verifyCertificate(bytes32 certificate) public returns (bool, bytes32, string memory) {
        bool result = certificate != bytes32(0) ? true : false;
        string memory data = "Data";
        return (result, publicKey, data);
    }
}

contract Authorise is ERC721{
    uint256 private tokenIdCounter;
    
    event InvalidCertificate(address indexed voter, string message);

    MockOracle oracle = new MockOracle();

    //list of eligible voters
    mapping(address => uint256) public eligibleVoters;

    constructor() ERC721("AuthoriseNFT", "ANT") {}
    function _incrementTokenId() private {
        tokenIdCounter++;
    }
    function _currentTokenId() private view returns (uint256) {
        return tokenIdCounter;
    }
    function mintToken(address user) internal {
        _incrementTokenId();
        uint256 newTokenId = _currentTokenId();
        _mint(user, newTokenId);
        eligibleVoters[user] = newTokenId;
    }

    function requestBallot(bytes32 _certificate, bytes memory _signature) public {
    bytes32 certificate = _certificate;
    //send the certificate to mock oracle
    (bool result, bytes32 publicKey, string memory data) = oracle.verifyCertificate(certificate);
    if (result) {
        // Verify the signature
        //recoveredAddress = the location the publicKey was derived from (so the certificate)

        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", certificate));
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);
        address recoveredAddress = ecrecover(hash, v, r, s);

        if (recoveredAddress == address(uint160(uint256(publicKey)))) {
            //if the signature is valid, and certificate authentic
            //assign a unique NFT token to the voter
            mintToken(msg.sender);
        } else {
            // The signature is invalid, emit an event
            emit InvalidCertificate(msg.sender, "Invalid signature");
        }
    } else {
        //send a message to the user that the certificate is invalid
        emit InvalidCertificate(msg.sender, "Certificate is invalid");
    }   
    }

    function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8 v, bytes32 r, bytes32 s)
{
    require(sig.length == 65);

    assembly {
        // first 32 bytes, after the length prefix
        r := mload(add(sig, 32))
        // second 32 bytes
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(sig, 96)))
    }

    return (v, r, s);
}

}