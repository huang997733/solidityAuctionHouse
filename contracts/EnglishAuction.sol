// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;
    
    uint public endTime;
    uint public currentPrice;
    address currentWinner;

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _minimumPriceIncrement)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        endTime = time() + biddingPeriod;
        currentPrice = 0;
    }

    function bid() public payable{
        uint min;
        if (currentPrice == 0) {
            min = initialPrice;
        }
        else {
            min = currentPrice + minimumPriceIncrement;
        }
        
        require(msg.value >= min && time() < endTime);
        refundToBuyer = currentPrice;
        currentPrice = msg.value;
        currentWinner = msg.sender;
        endTime = time() + biddingPeriod;
    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){
        if (time() < endTime)
            return address(0);
        return currentWinner;
    }
}
