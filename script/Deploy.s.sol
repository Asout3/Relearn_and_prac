// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/Asout3Token.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        new Asout3Token("Asout3 Token", "AST", 18, 100000 ether);

        vm.stopBroadcast();
    }
}
