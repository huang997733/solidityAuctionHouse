// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract VickreyAuction is Auction {

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;

    uint public highestBid;
    uint public secondHighestBid;
    mapping (address => bytes32) public bids;

    // constructor
    constructor(address _sellerAddress,
                            address _judgeAddress,
                            address _timerAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;

        // TODO: place your code here
    }

    // Record the player's bid commitment
    // Make sure exactly bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable {
        require(time() < biddingDeadline);
        if (bids[msg.sender] == 0)
            require(msg.value == bidDepositAmount);
        if (bids[msg.sender] != 0)
            require(msg.value == 0);
        bids[msg.sender] = bidCommitment;
    }

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(bytes32 nonce) public payable{
        require(keccak256(abi.encodePacked(msg.value, nonce)) == bids[msg.sender]);
        require(time() >= biddingDeadline && time() < revealDeadline);

        if(msg.value < minimumPrice)
            balances[msg.sender] = bidDepositAmount+msg.value;
        
        else if(msg.value < highestBid){
            balances[msg.sender] = bidDepositAmount + msg.value;

            if (msg.value > secondHighestBid)
                secondHighestBid = msg.value;
        }
        else if(msg.value > highestBid){
            if(highestBid != 0){
                secondHighestBid = highestBid;
                balances[winnerAddress] = highestBid+bidDepositAmount;
            }
            highestBid = msg.value;
            winnerAddress = msg.sender;
            balances[msg.sender] = bidDepositAmount;
        }

    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){
        // TODO: place your code here
        return winnerAddress;
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public override {
        require(time() >= revealDeadline);
        uint refund;
        if (secondHighestBid != 0)
            refund = highestBid - secondHighestBid;
        else
            refund = highestBid - minimumPrice;
        balances[getWinner()] = bidDepositAmount+refund;
        // call the general finalize() logic
        super.finalize();
    }
}
