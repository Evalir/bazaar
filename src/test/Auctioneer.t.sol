// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Auctioneer} from "src/Auctioneer.sol";

contract GreeterTest is Test {
    using stdStorage for StdStorage;

    Auctioneer auctioneer;

    event GMEverybodyGM();

    function setUp() external {
        auctioneer = new Auctioneer();
    }
}
