// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {Auctioneer} from "src/Auctioneer.sol";

contract Deploy is Script {
    function run() external returns (Auctioneer auctioneer) {
        vm.startBroadcast();
        auctioneer = new Auctioneer();
        vm.stopBroadcast();
    }
}
