// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console2} from "forge-std/Script.sol";
import {UResolverRegistry} from "../src/UResolverRegistry.sol";
import {UAuditRegistry} from "../src/UAuditRegistry.sol";
import {WrappedUR_AuditedResolver} from "../src/wrappers/WrappedUR_AuditedResolver.sol";
import {ENSRegistry} from "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";
import {SimpleResolver} from "../src/mocks/SimpleResolver.sol";
import {UR} from "@unruggable-resolve/contracts/UR.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddressResolver.sol";
import {BytesUtils} from "../src/utils/BytesUtils.sol";

contract DemoAuditedResolver is Script {
    address sender = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy ENS Registry
        ENSRegistry ensRegistry = new ENSRegistry();
        console2.log("ENSRegistry deployed at:", address(ensRegistry));

        // Deploy UR with no gateways
        string[] memory gateways = new string[](0);
        UR ur = new UR(address(ensRegistry), gateways);
        console2.log("UR deployed at:", address(ur));

        // Deploy SimpleResolver
        SimpleResolver simpleResolver = new SimpleResolver(ensRegistry, sender);
        console2.log("SimpleResolver deployed at:", address(simpleResolver));

        // Deploy audit registry
        UAuditRegistry auditRegistry = new UAuditRegistry(sender);
        console2.log("UAuditRegistry deployed at:", address(auditRegistry));

        // Deploy wrapped UR
        WrappedUR_AuditedResolver wrappedUR = new WrappedUR_AuditedResolver(
            ur,
            auditRegistry
        );
        console2.log("WrappedUR_AuditedResolver deployed at:", address(wrappedUR));

        // Set up ENS name
        bytes32 ethNamehash = BytesUtils.namehash("\x03eth\x00", 0);
        bytes32 nameEthNamehash = BytesUtils.namehash("\x04name\x03eth\x00", 0);

        // Register .eth and name.eth with the correct owner
        ensRegistry.setSubnodeOwner(bytes32(0), keccak256(bytes("eth")), sender);
        ensRegistry.setSubnodeOwner(ethNamehash, keccak256(bytes("name")), sender);
        
        // Set resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, address(simpleResolver));
        
        // Set address for name.eth
        simpleResolver.setAddr(nameEthNamehash, 60, abi.encodePacked(sender));
        console2.log("Set address for name.eth to:", sender);

        // Try to resolve before setting audit ID (should fail)
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));
        bytes[] memory calls = new bytes[](1);
        calls[0] = addrCall;

        console2.log("Attempting to resolve before setting audit ID (should fail)...");
        try wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0)) {
            console2.log("Unexpected: Resolution succeeded when it should have failed");
        } catch {
            console2.log("Expected: Resolution failed because resolver is not audited");
        }

        // Set audit ID and try again
        auditRegistry.setAuditId(address(simpleResolver), 1);
        console2.log("Set audit ID for resolver to 1");

        console2.log("Attempting to resolve after setting audit ID...");
        try wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0)) {
            console2.log("Success: Resolution succeeded after setting audit ID");
        } catch {
            console2.log("Unexpected: Resolution failed after setting audit ID");
        }

        vm.stopBroadcast();
    }
} 