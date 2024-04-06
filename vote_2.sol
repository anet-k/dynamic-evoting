//steps
//5a.1 user sends encrypted choice to the transaction together with NFT token
//5a.2 smart contract stores the pair (choice, NFT token) in the list of commitments
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


pragma solidity ^0.8.25;

// SPDX-License-Identifier: UNLICENSED

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SubmitVote {
    IERC721 public nft;
    //constructor(address _nft) {
    //    nft = IERC721(_nft);
    //}

    struct Vote{
        uint256 timestamp;
        bytes32 choice;
        uint256 tokenId;
        bool isOriginalVote;
        uint256 previousVoteIndex;
    }

    struct BlindedVote {
        bytes32 blindedVote; //encrypted choice
        uint256 timestamp;
        uint256 nftTokenId;
    }

    mapping(uint256 => BlindedVote) public blindedChoices;
    mapping(uint256 => Vote[]) public votes;

    event VoteAltered(address voter);

    //submit blinded vote - submit the commitment
    function submitCommitment(bytes32 blindedChoice, uint256 tokenId) public {
        require(nft.ownerOf(tokenId) == msg.sender, "Unauthorised access");
            
            //5a.2 smart contract stores the pair (choice, NFT token) in the list of commitments
            //store the blinded choice
            blindedChoices[tokenId] = BlindedVote({
                blindedVote: blindedChoice,
                timestamp: block.timestamp,
                nftTokenId: tokenId
            });
    }

    //submit unblinded vote
    function verifyVote(bytes32 choice, uint256 tokenId) public {
        //5b.1.1.1 smart contract check if the NFT token is valid, then proceed with 5b.1.2
        require(nft.ownerOf(tokenId) == msg.sender, "Unauthorised access"); //5b.1.1.2 if the token is invalid then "Unauthorised access"

         //5b.2 verifies the ballot by matching the choice with the blinded choice - the reveal phase
        require(blindedChoices[tokenId].blindedVote == keccak256(abi.encodePacked(choice)), "Invalid vote");

        //if they match then create a Vote, and if it's the first for that NFT mark is as isOriginal, while alterationVote is empty for now
        Vote memory vote = Vote({
            timestamp: block.timestamp,
            choice: choice,
            tokenId: tokenId,
            isOriginalVote: true,
            previousVoteIndex: type(uint256).max //invalid index. this Vote has no alterations
        });
        
        //store the vote pair, vote + token
        votes[tokenId].push(vote);
    }

    //submit altered vote
    function requestAlteration(bytes32 originalProof, uint256 tokenId) public {
        //check nft ownership
        require(nft.ownerOf(tokenId) == msg.sender, "Unauthorised access");

        //verify original vote
        //check if originalProof is the same as the original vote
        Vote memory originalVote = getOriginalVote(tokenId);
        bytes32 originalVoteHash = keccak256(abi.encode(originalVote));
        require(originalVoteHash == originalProof, "Invalid original vote");
    }

    function commitAlteration(bytes32 alterationChoice, uint256 tokenId) public {
        //require result of requestAlteration to be true
        //require(requestAlteration(originalProof, tokenId), "Invalid request"); //but we are not passing originalProof here. 
        //require(nft.ownerOf(tokenId) == msg.sender, "Unauthorised access");

         //add alterationChoice to commitments = blindedChoices
        blindedChoices[tokenId] = BlindedVote({
            blindedVote: alterationChoice,
            timestamp: block.timestamp,
            nftTokenId: tokenId
        });
    } 

    function verifyAlteration(bytes32 alterationVote, uint256 tokenId) public {
        //compare alterationVote with blindedChoice
        require(blindedChoices[tokenId].blindedVote == keccak256(abi.encodePacked(alterationVote)), "Invalid alteration");
        //create new altered vote
        Vote memory vote = Vote({
            timestamp: block.timestamp,
            choice: alterationVote,
            tokenId: tokenId,
            isOriginalVote: false,
            previousVoteIndex: votes[tokenId].length - 1
        });

        //store the altered vote, associated with the nft, but without removing the original vote
        votes[tokenId].push(vote);

        //let user know the vote was altered, while minimising linking to identity
        emit VoteAltered(msg.sender);
    }
    //returns the original vote for a given token
    function getOriginalVote(uint256 tokenId) public view returns(Vote memory){
        //check nft ownership
        require(nft.ownerOf(tokenId) == msg.sender, "Unauthorised access");

        require(votes[tokenId].length > 0, "No votes found for this token");
        return votes[tokenId][0];
    }

    //return all votes for a given token
    function getVotes(uint256 tokenId) public view returns(Vote[] memory){
        return votes[tokenId];
    }

    //return the latest alteration (latest vote for a given token)
    function getLatestVote(uint256 tokenId) public view returns(Vote memory){
        require(votes[tokenId].length > 0, "No votes found for this token");
        return votes[tokenId][votes[tokenId].length - 1];
    }
}
