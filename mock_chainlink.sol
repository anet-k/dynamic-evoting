// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/**
   * @title MockVerifier
   * @dev ContractDescription
   * @custom:dev-run-script mock_verifier.sol
   */
// 
// Import Chainlink contracts
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol" as ChainlinkClientMock;


contract MockVerifier is ChainlinkClientMock.ChainlinkClient{


    // This will simulate the public key returned by the verifier
    bytes32 public mockPublicKey = "0x123456789abcdef";

    //constructor (address _link, address _oracle) {
       // _setChainlinkToken(_link);
       // _setChainlinkOracle(_oracle);
   //}

    function verifyCertificate(bytes32 certificate) public view returns (bytes32) {
        // Here you can add logic to simulate the verification of the certificate
        // For this mock contract, we'll just return the mock public key
        return mockPublicKey;
    }

    function fulfillOracleRequest (bytes32 _requestId, bytes32 _publicKey) public recordChainlinkFulfillment(_requestId)returns (bool){
        // This function will be called by the Chainlink node
        // It will set the public key to the value returned by the node
        mockPublicKey = _publicKey;
        return true;
    }
}
