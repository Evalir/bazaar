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

    /// @dev Emits when an action inteded to be made during the bid period is made outside it.
    error NotBidPeriod();
    /// @dev Emits when an action intended to be made during hte reveal period is made outside it.
    error NotRevealPeriod();
    /// @dev Emits when the bid period duration is zero on the constructor.
    error ZeroBidTime();
    /// @dev Emits when the reveal period duration is zero on the constructor.
    error ZeroRevealTime();

    modifier onlyBid() {
        // TODO: Double check bound math
        if (block.timestamp > auctionStartTime + bidPeriodDuration || block.timestamp < auctionStartTime) {
            revert NotBidPeriod();
        }
        _;
    }

    modifier onlyReveal() {
        // TODO: Double check bound math
        if (
            // Reveal attempt after auction ends
            block.timestamp > auctionStartTime + bidPeriodDuration + revealPeriodDuration
            // Reveal attempt before bid period ends
                || block.timestamp < auctionStartTime + bidPeriodDuration
        ) {
            revert NotRevealPeriod();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _bidPeriodDuration, uint256 _revealPeriodDuration) {
        if (_bidPeriodDuration == 0) revert ZeroBidTime();
        if (_revealPeriodDuration == 0) revert ZeroRevealTime();
        bidPeriodDuration = _bidPeriodDuration;
        revealPeriodDuration = _revealPeriodDuration;
    }

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function bid() external payable {
        require(block.timestamp < bidPeriodDuration, "Auctioneer: bid period is over");
        emit Bid(msg.sender, msg.value);
    }

    function reveal() external {}

    function withdraw() external {}

    /*//////////////////////////////////////////////////////////////
                        NATIVE TOKEN HANDLING
    //////////////////////////////////////////////////////////////*/

    fallback() external payable {}

    receive() external payable {}
}
