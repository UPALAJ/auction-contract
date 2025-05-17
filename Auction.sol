// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Auction {
    
    address auctionHost;
    string currentAuctionItem; // set it to string just for this version of this contract
    address highestBidder;
    uint256 highestBid = 0;
    string summaryText;

    struct AuctionStatusStruct {
        bool openOrClose;
        string item;
    }

    AuctionStatusStruct private auctionStatusBody;

    event winnerAnnouncement(address winner, string prize, string summary);

    constructor() {
        // genesis host is smart contract deployer
        auctionHost = msg.sender;
        auctionStatusBody.openOrClose = false;
        auctionStatusBody.item = "genesis";
    }

    modifier checkHost() {
        require(msg.sender == auctionHost, "You are not the host of this auction!");
        _;
    }

    modifier checkOpen() {
        require(auctionStatusBody.openOrClose == false, "Auction is currently open");
        _;
    }

    modifier checkClose() {
        require(auctionStatusBody.openOrClose == true, "cannot close, no auction at the moment!");
        _;
    }

    function status() view external returns (AuctionStatusStruct memory) {
        if (auctionStatusBody.openOrClose == true) {
            return auctionStatusBody;
        } else {
            return AuctionStatusStruct(false, "nothing is in auction");
        }
    }

    function openAuction(string memory thingToAuction) external checkOpen {
        auctionHost = msg.sender;
        currentAuctionItem = thingToAuction;
        auctionStatusBody.openOrClose = true;
        auctionStatusBody.item = thingToAuction;
        
    }

    function closeAuction() external checkHost checkClose {
        summaryText = string(abi.encodePacked(
                                            "The winner of \"",
                                            auctionStatusBody.item,
                                            "\" is \"",
                                            Strings.toHexString(uint256(uint160(highestBidder)), 20)
                                            ));
        emit winnerAnnouncement(highestBidder, auctionStatusBody.item, summaryText);
        auctionHost = address(0);
        auctionStatusBody.openOrClose = false;
        auctionStatusBody.item = "auction is now closed, feel free to be a new host";
        highestBid = 0;
        highestBidder = address(0);
    }

    function bid(uint256 inputBid) external checkClose {
        if (inputBid > highestBid) {
            highestBidder = msg.sender;
            highestBid = inputBid;
        } else {
            revert("Your bid is not higher than the highest bid");
        }
    }

    function whoIsTheHost() view external returns (address){
        return auctionHost;
    }

    function hello() view external returns (string memory) {
        return string(abi.encodePacked("this is testing ",Strings.toHexString(uint256(uint160(msg.sender)), 20)));
    }
}
