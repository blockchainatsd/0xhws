// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Auction is IERC721Receiver {
    // TODO: make a tokenDetails struct

    // TODO: make a mapping from id to tokenDetails

    // TODO: event for selling auction
    
    /**
       TODO: Seller puts the item on auction
    */
    function createTokenAuction(
        address _nft,
        uint256 _tokenId,
        uint128 _price,
        uint256 _duration
    ) external { }
    
    /**
       Users bid for a particular nft, the max bid is compared and set if the current bid id highest
    */
    function bid(address _nft, uint256 _tokenId) external payable {
        // TODO:  
    }
    /**
       Called by the seller when the auction duration is over the hightest bid user get's the nft and other bidders get eth back
    */
    function executeSale(address _nft, uint256 _tokenId) external {
        // TODO: next workshop
    }


    function getTokenAuctionDetails(address _nft, uint256 _tokenId) public view returns (tokenDetails memory) {
        // TODO: return token auction details
    }


    receive() external payable {}
}