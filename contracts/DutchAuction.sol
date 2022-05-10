// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;

    uint public currentPrice;
    uint public startTime;

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;

        startTime = time();
    }


    function bid() public payable{
        currentPrice = initialPrice - ((time() - startTime) * offerPriceDecrement);
        require(msg.value >= currentPrice && time() < startTime + biddingPeriod && getWinner() == address(0));
        winnerAddress = msg.sender;
        winningPrice = currentPrice;
        balances[msg.sender] = msg.value - currentPrice;
    }

}
