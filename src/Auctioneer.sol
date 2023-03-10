// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Auctioneer {
    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/
    address public highestBidder;
    uint256 public bidPeriodDuration;
    uint256 public revealPeriodDuration;

    event Bid(address indexed bidder, uint256 amount);

    error BidPeriodNotOver();
    error RevealPeriodNotOver();

    constructor(uint256 _bidPeriodDuration, uint256 _revealPeriodDuration) {
        bidPeriodDuration = _bidPeriodDuration;
        revealPeriodDuration = _revealPeriodDuration;
    }

    function bid() external payable {
        require(
            block.timestamp < bidPeriodDuration,
            "Auctioneer: bid period is over"
        );
        emit Bid(msg.sender, msg.value);
    }
}
