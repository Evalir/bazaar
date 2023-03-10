// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Auctioneer {
    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/
    /// @dev The highest bidder, so far.
    address public highestBidder;
    /// @dev The highest bid, so far.
    uint256 public highestBid;
    /// @dev The receiver of the auction proceeds.
    address public beneficiary;
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

    mapping(address => Bid) public bids;

    /// @dev The bid structure.
    struct Bid {
        bytes32 blindedBid;
        uint256 amount;
    }

    event Bidded(address indexed bidder, bytes32 blindedBid);
    event Revealed(address indexed bidder, uint256 amount);
    event Withdrawn(address indexed bidder, uint256 amount);

    /// @dev Emits when an action inteded to be made during the bid period is made outside it.
    error NotBidPeriod();
    /// @dev Emits when an action intended to be made during hte reveal period is made outside it.
    error NotRevealPeriod();
    /// @dev Emits when the bid period duration is zero on the constructor.
    error ZeroBidTime();
    /// @dev Emits when the reveal period duration is zero on the constructor.
    error ZeroRevealTime();
    /// @dev Emits when the bid revealed is invalid.
    error InvalidReveal(bytes32 expected, bytes32 actual);
    /// @dev Emits when the highest bidder tries to withdraw.
    error InvalidHighestBidderWithdrawal();

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
            block
                // Reveal attempt after auction ends
                .timestamp > auctionStartTime + bidPeriodDuration + revealPeriodDuration
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

    constructor(uint256 _bidPeriodDuration, uint256 _revealPeriodDuration, address _bidToken, address _beneficiary) {
        if (_bidPeriodDuration == 0) revert ZeroBidTime();
        if (_revealPeriodDuration == 0) revert ZeroRevealTime();

        bidPeriodDuration = _bidPeriodDuration;
        revealPeriodDuration = _revealPeriodDuration;
        bidToken = IERC20(_bidToken);
        beneficiary = _beneficiary;
    }

    /*//////////////////////////////////////////////////////////////
                          EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Place a blinded bid. The bid hash should be equal to keccak256(abi.encodePacked(value, secret)).
    /// @dev The user must approve the auctioneer to transfer the bid amount.
    /// An user can bid multiple times, but this will only update his bid, not add a new one.
    /// He can't place bids which are lower than his previous bid.
    function bid(bytes32 blindedBid) external onlyBid {
        bids[msg.sender] = Bid(blindedBid, 0);

        emit Bidded(msg.sender, blindedBid);
    }

    /// @notice Reveal your blinded bid. This should match keccak256(abi.encodePacked(value, secret)).
    /// @dev The user must approve the auctioneer to transfer the bid amount.
    function reveal(bytes32 secret, uint256 bidAmount) external {
        Bid storage _bid = bids[msg.sender];
        bytes32 bidHash = keccak256(abi.encodePacked(bidAmount, secret));

        if (_bid.blindedBid != bidHash) revert InvalidReveal(_bid.blindedBid, bidHash);

        if (bidAmount > highestBid) {
            highestBid = bidAmount;
            highestBidder = msg.sender;

            bidToken.transferFrom(msg.sender, address(this), bidAmount);
            _bid.amount = bidAmount;

            emit Revealed(msg.sender, bidAmount);
        }
    }

    /// @notice Withdraw your funds, if you are not the highest bidder.
    function withdraw() external {
        if (msg.sender == highestBidder) revert InvalidHighestBidderWithdrawal();

        uint256 amount = bids[msg.sender].amount;
        bidToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
}
