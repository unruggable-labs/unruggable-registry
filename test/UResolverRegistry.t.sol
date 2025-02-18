// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { UResolverRegistry } from "../src/UResolverRegistry.sol";
import { ENS } from "../src/ENS.sol";
import { MockENSRegistry } from "../src/MockENSRegistry.sol";
import { BytesUtils } from "../src/BytesUtils.sol";
// import custom errors
import { NoResolverAtOrBeforeBlock, NotOwnerOrApprovedController } from "../src/UResolverRegistry.sol";

// Ownable error
error OwnableUnauthorizedAccount(address account);

contract UResolverRegistryTest is Test {
    using BytesUtils for bytes;

    UResolverRegistry private registry;
    MockENSRegistry ens;
    address private ensOwner = address(0x1);
    address private nameOwner = address(0x2);
    address private unauthorized = address(0x4);
    address private uResolverRegistryOwner = address(0x8);

    // Resolver addresses
    address private resolver = address(0x5);
    address private resolver2 = address(0x6);
    address private resolver3 = address(0x7);

    // Block times for testing
    uint64 private blockTime = 1641070100;
    uint64 private blockTime2 = blockTime + 100;
    uint64 private blockTime3 = blockTime + 200;

    // DNS-encoded name for "example.eth" using string literal format
    bytes private dnsEncodedName = "\x07example\x03eth\x00";

    // Compute the node hash using the namehash function
    bytes32 private node = dnsEncodedName.namehash(0);

    function setUp() public {
        vm.startPrank(ensOwner);
        vm.warp(blockTime); 

        // create the mock ens registry
        ens = new MockENSRegistry(ensOwner);

        // Set initial resolver for the node in the mock registry
        ens.setOwner(node, nameOwner); // Example resolver address
        vm.stopPrank();

        vm.startPrank(uResolverRegistryOwner);
        registry = new UResolverRegistry(address(ens));
        vm.stopPrank();
    }

    function test1000________________________________________________________________________________() public {}
    function test2000__________________________URESOLVER_REGISTRY_____________________________________() public {}
    function test3000________________________________________________________________________________() public {}

    function test_001____getResolver_________________ReturnsCorrectResolver() public {
        vm.startPrank(nameOwner);
        vm.warp(blockTime); 
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        (address resolver, uint64 blockTime) = registry.getResolver(node, uint64(block.timestamp));
        assertEq(resolver, ens.resolver(node));
        assertEq(blockTime, uint64(block.timestamp));
    }

    function test_002____getResolverNoRecord_________RevertsWhenNoRecord() public {
        vm.startPrank(nameOwner);
        vm.warp(blockTime); 
        vm.expectRevert(abi.encodeWithSelector(NoResolverAtOrBeforeBlock.selector, uint64(block.timestamp)));
        registry.getResolver(node, uint64(block.timestamp));
    }

    function test_003____latestResolver______________ReturnsLatestResolver() public {
        vm.startPrank(nameOwner);
        vm.warp(blockTime); 
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        (address resolver, uint64 blockTime) = registry.latestResolver(node);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockTime, uint64(block.timestamp));
    }

    function test_004____registerResolver____________RegistersResolverCorrectly() public {
        vm.startPrank(nameOwner);
        vm.warp(blockTime); 
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        (address resolver, uint64 blockTime) = registry.latestResolver(node);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockTime, uint64(block.timestamp));
    }

    function test_005____registerResolverUnauthorized_RevertsWhenUnauthorized() public {
        vm.startPrank(unauthorized);
        vm.warp(blockTime); 
        vm.expectRevert(abi.encodeWithSelector(NotOwnerOrApprovedController.selector));
        registry.registerResolver(node);
    }

    function test_008____registerMultipleResolvers___RegistersAndRetrievesCorrectly() public {
        vm.startPrank(nameOwner);
        ens.setResolver(node, resolver);
        registry.registerResolver(node);

        // Advance block time and register second resolver
        vm.warp(blockTime2);
        ens.setResolver(node, resolver2);
        registry.registerResolver(node);

        // Advance block time and register third resolver
        vm.warp(blockTime3);
        ens.setResolver(node, resolver3);
        registry.registerResolver(node);

        // Check resolver at block time after the third registration
        (address resolvedAddress, ) = registry.getResolver(node, blockTime3 + 1);
        assertEq(resolvedAddress, resolver3);

        // Check resolver between the second and third block time
        (resolvedAddress, ) = registry.getResolver(node, blockTime2 + 50);
        assertEq(resolvedAddress, resolver2);

        // Check resolver exactly at the first block time
        (resolvedAddress, ) = registry.getResolver(node, blockTime);
        assertEq(resolvedAddress, resolver);
    }
} 