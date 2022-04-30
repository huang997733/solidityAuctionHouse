// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Timer.sol";

contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint winningPrice;
    uint refundToBuyer;
    uint moneyToSeller;

    // constructor
    constructor(address _sellerAddress,
                     address _judgeAddress,
                     address _timerAddress) {

        judgeAddress = _judgeAddress;
        timerAddress = _timerAddress;
        sellerAddress = _sellerAddress;
        if (sellerAddress == address(0))
          sellerAddress = msg.sender;
    }

    // This is provided for testing
    // You should use this instead of block.number directly
    // You should not modify this function.
    function time() public view returns (uint) {
        if (timerAddress != address(0))
          return Timer(timerAddress).getTime();

        return block.number;
    }

    function getWinner() public view virtual returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint price) {
        return winningPrice;
    }

    // If no judge is specified, anybody can call this.
    // If a judge is specified, then only the judge or winning bidder may call.
    function finalize() public virtual {
        if (judgeAddress != address(0))
            require(msg.sender == judgeAddress || msg.sender == getWinner());
        require(getWinner() != address(0));

        moneyToSeller = winningPrice;
    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public {
        require(getWinner() != address(0));
        require(msg.sender == judgeAddress || msg.sender == sellerAddress);
        refundToBuyer = address(this).balance;
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public {
        
        if (msg.sender == sellerAddress && moneyToSeller != 0)
            payable(msg.sender).transfer(moneyToSeller);
            moneyToSeller = 0;
        if (msg.sender == winnerAddress && refundToBuyer != 0)
            payable(msg.sender).transfer(refundToBuyer);
            refundToBuyer = 0;
    }

}
