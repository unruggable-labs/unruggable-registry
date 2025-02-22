// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {WrappedUR_AuditedResolver} from "../src/wrappers/WrappedUR_AuditedResolver.sol";
import {BytesUtils} from "../src/utils/BytesUtils.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddressResolver.sol";
import {Lookup, Response} from "@unruggable-resolve/contracts/IUR.sol";

contract ResolveNameEth is Script {
    function setUp() public {}

    function run(address wrappedURAddress) public {
        // Create an instance of the WrappedUR_AuditedResolver
        WrappedUR_AuditedResolver wrappedUR = WrappedUR_AuditedResolver(wrappedURAddress);

        // Set up ENS name
        bytes32 nameEthNamehash = BytesUtils.namehash("\x04name\x03eth\x00", 0);

        // Prepare the call to resolve the address
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));
        bytes[] memory calls = new bytes[](1);
        calls[0] = addrCall;

        // Attempt to resolve name.eth
        console.log("Attempting to resolve name.eth...");
        try wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0)) returns (Lookup memory lookup, Response[] memory results) {
            address resolvedAddress = address(bytes20(results[0].data));
            console.log("Success: Resolved address for name.eth is:", resolvedAddress);
        } catch {
            console.log("Failed: Could not resolve name.eth");
        }
    }
}
