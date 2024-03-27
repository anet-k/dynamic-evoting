//steps
//5a.1 user sends encrypted choice to the transaction together with NFT token
//5a.2 smart contract stores the pair (choice, NFT token) in the list of committments
//5b.1.1 user sends a ballot with the NFT token and the choice (not encrypted)
//5b.1.1.1 smart contract check if the NFT token is valid, then proceed with 5b.1.2
//5b.1.1.2 if the token is invalid then "Unauthorised access"
//5b.1.2 smart contract accepts the ballot
//5b.2 smart contract verifies the choice: by matching the encrypted choice with the choice on the ballot
//5b.2.1 if the choices match, then store the pair
//5b.2.3 if the choices do not match, then "Invalid vote"
//6a user upploads the ballot on the blockchain in a transaction, and smart contract stores the submitted ballot - linked list now
//alteration
//6b.1.1 user proves their original vote - by sending hash of the original ballot to the smart contract
//6b.1.2.1 smart contract checks if the hash is in the list of ballots
//6b.1.2.3 if the hash is not in the list, then "Invalid proof"
//6b.1.3 if the hash is in the list, then the smart contract accepts the proof, and user is permitted to submit alteration
//6b.1.4 the user then does steps similar to 5a.1-5b.2, but altered choice is uploaded ona subchain under the original vote as header (instead of 6a)
//6b.1.5 smart contract stores the altered vote
//6b.1.6 smart contract stores the proof of alteration





pragma solidity >=0.8.0 <0.9.0;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Vote {
    IERC721 public nft;
    constructor(address _nft) {
        nft = IERC721(_nft);
    }

    struct Vote {
        string choice;
        uint256 timestamp;
        uint256 alterationVote;
    }

    struct BlindedVote {
        bytes blindedVote; //encrypted choice
        uint256 timestamp;
        uint256 nftTokenId;
    }

    struct AlteredVote {
        string choice;
        uint256 timestamp;
        uint256 originalVote;
    }

    mapping(address => uint256 ) public originalVotes;
    mapping(address => BlindedVote) public blindedChoices;
    mapping(address => Vote[]) public votes;
    mapping(bytes32 => bool) public voteProofs;     //proof of submit votes
    mapping(uint256 => AlteredVote) public alteredVotes;

//5a.1 user sends encrypted choice to the transaction together with NFT token
    function submitComittment(string memory blindedChoice, uint256 tokenId) public {
        require(nft.ownerOf(tokenId) == msg.sender, "Unauthorised access");
            
            //5a.2 smart contract stores the pair (choice, NFT token) in the list of committments
            //store the blinded choice
            blindedChoices[msg.sender] = BlindedVote({
                blindedVote: blindedChoice,
                timestamp: block.timestamp,
                nftTokenId: tokenId
            }); 
    }

    function verifyBallot(string memory choice, uint256 token) public {
        //5b.1.1.1 smart contract check if the NFT token is valid, then proceed with 5b.1.2
        require(nft.ownerOf(token) == msg.sender, "Unauthorised access");

        //5b.1.1.2 if the token is invalid then "Unauthorised access"
        //5b.1.2 smart contract accepts the ballot
        votes[msg.sender].push(Vote({choice: choice,timestamp: block.timestamp}));

        //5b.2 smart contract verifies the choice: by matching the encrypted choice with the choice on the ballot
        require(keccak256(abi.encodePacked(choice)) == blindedChoices[msg.sender].blindedVote, "Invalid vote");  //otherwise reverts transaction

        //5b.2.1 if the choices match, then store the pair
        blindedChoices[msg.sender] = BlindedVote({
            blindedVote: unblindedChoice,
            timestamp: block.timestamp,
            nftTokenId: token
        });

    }

    //alter
    function submitAlteredVote(bytes32 originalVotes, string memory AlteredVote, uint256 token) public {
        require(nft.ownerOf(token) == msg.sender, "Unauthorised access");

        uint256 originalVote = originalVotes[msg.sender];
        require(keccak256(abi.encodePacked(votes[originalVote].choice)) == originalVotes, "Invalid proof");

        alteredVotes.push(AlteredVote({
            choice: AlteredVote,
            timestamp: block.timestamp,
            originalVote: originalVote
        }));

        //new alterations will replace previous alterations
        if (votes[originalVote].nextVote != 0) {
            alteredVotes[votes[originalVote].nextVote].nextVote = alteredVote;
        }

        votes[originalVote].nextVote = alteredVote;


    }





    function vote(bytes memory unblindedChoice) public {
        //verify unblinded matches the blinded chocie
        require(verifyChoice(unblindedChoice), blindedChoices[msg.sender].blindedVote);
    }

    function verifyChoice(bytes memory unblindedChoice, bytes memory blindedChoice) public pure returns (bool) {
        //verify unblinded matches the blinded chocie
        require(keccak256(unblindedChoice)(abi.encodePacked()) == blindedChoices[msg.sender].blindedVote, "Vote does not match");
    }

    function commitVote(bytes memory blindedVote) public {
        //store the blinded vote
        blindedChoices[msg.sender] = BlindedVote({
            blindedVote: blindedVote
        });
    }

    function revealVote(bytes memory unblindedVote) public {
        //verify unblinded matches the blinded chocie
        require(verifyChoice(unblindedVote), blindedChoices[msg.sender].blindedVote);
    }

    function castVote(string memory choice) public {
        //store the vote
        votes[msg.sender].push(Vote({choice: choice,timestamp: block.timestamp}));
    }

    function requestVoteChange(string memory originalVote) public {

    }
    
}