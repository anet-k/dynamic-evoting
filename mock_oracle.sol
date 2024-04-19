pragma solidity ^0.8.25;

contract MockOracle {
    bytes32 public publicKey = "PublicKey";

    function verifyCertificate(bytes32 certificateHash) public returns (bool, bytes32, string memory) {
        bool result = certificateHash != bytes32(0) ? true : false;
        string memory data = "Data";
        return (result, publicKey, data);
    }
}