// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

address constant NATIVE_ASSET = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

contract Auctioneer {
    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @dev The highest bidder, so far.
    address public highestBidder;
    /// @dev The auction start time.
    /// The auction in total lasts `bidPeriodDuration + revealPeriodDuration`.
    /// Therefore the auction end time is `auctionStartTime + bidPeriodDuration + revealPeriodDuration`.
    uint256 public auctionStartTime;
    /// @dev The bid period duration after deployment.
    uint256 public bidPeriodDuration;
    /// @dev The reveal period duration after the bid period.
    uint256 public revealPeriodDuration;

    /// @dev The token used for bidding.
    IERC20 public bidToken;

    event Bid(address indexed bidder, uint256 amount);

    error BidPeriodNotOver();
    error RevealPeriodNotOver();
    error ZeroBidTime();
    error ZeroReavealTime();

    constructor(uint256 _bidPeriodDuration, uint256 _revealPeriodDuration) {
        if (_bidPeriodDuration == 0) revert ZeroBidTime();
        if (_revealPeriodDuration == 0) revert ZeroReavealTime();
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
