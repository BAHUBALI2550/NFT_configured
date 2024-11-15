
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/Nft.sol";
import {console} from "forge-std/console.sol";

contract DeployNft is Script {

    function run() external returns (NFT) {
        vm.startBroadcast();
        NFT nft = new NFT(msg.sender);
        vm.stopBroadcast();
        return nft;
    }
}
