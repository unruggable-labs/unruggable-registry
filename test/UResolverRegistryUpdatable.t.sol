// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { UResolverRegistryUpdatable } from "../src/UResolverRegistryUpdatable.sol";
import { ENS } from "../src/ENS.sol";
import { MockENSRegistry } from "../src/MockENSRegistry.sol";
import { BytesUtils } from "../src/BytesUtils.sol";
// import custom errors
import { NoResolverAtOrBeforeBlock, NotOwnerOrApprovedController } from "../src/UResolverRegistry.sol";

// Ownable error
error OwnableUnauthorizedAccount(address account);

contract UResolverRegistryUpdatableTest is Test {
    using BytesUtils for bytes;

    UResolverRegistryUpdatable private registry;
    MockENSRegistry ens;
    address private ensOwner = address(0x1);
    address private nameOwner = address(0x2);
    address private unauthorized = address(0x4);
    address private uResolverRegistryOwner = address(0x8);

    // Resolver addresses
    address private resolver = address(0x5);
    address private resolver2 = address(0x6);
    address private resolver3 = address(0x7);

    // Block numbers for testing
    uint256 private blocknumber = 1641070100;
    uint256 private blocknumber2 = blocknumber + 100;
    uint256 private blocknumber3 = blocknumber + 200;

    // DNS-encoded name for "example.eth" using string literal format
    bytes private dnsEncodedName = "\x07example\x03eth\x00";

    // Compute the node hash using the namehash function
    bytes32 private node = dnsEncodedName.namehash(0);

    function setUp() public {

        vm.startPrank(ensOwner);
        vm.roll(blocknumber); 

        // create the mock ens registry
        ens = new MockENSRegistry(ensOwner);

        // Set initial resolver for the node in the mock registry
        ens.setOwner(node, nameOwner); // Example resolver address
        vm.stopPrank();

        vm.startPrank(uResolverRegistryOwner);
        registry = new UResolverRegistryUpdatable(address(ens));        
        vm.stopPrank();
    }

    function test1000________________________________________________________________________________() public {}
    function test2000_________________________URESOLVER_REGISTRY_UPDATABLE___________________________() public {}
    function test3000________________________________________________________________________________() public {}

    function test_001____getResolver_________________ReturnsCorrectResolver() public {
        vm.startPrank(nameOwner);
        vm.roll(blocknumber); 
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        (address resolver, uint256 blockNumber) = registry.getResolver(node, block.number);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockNumber, block.number);
    }

    function test_002____getResolverNoRecord_________RevertsWhenNoRecord() public {
        vm.startPrank(nameOwner);
        vm.roll(blocknumber); 
        vm.expectRevert(abi.encodeWithSelector(NoResolverAtOrBeforeBlock.selector, block.number));
        registry.getResolver(node, block.number);
    }

    function test_003____latestResolver______________ReturnsLatestResolver() public {
        vm.startPrank(nameOwner);
        vm.roll(blocknumber); 
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        (address resolver, uint256 blockNumber, uint256 index) = registry.latestResolver(node);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockNumber, block.number);
        assertEq(index, 0);
    }

    function test_004____registerResolver____________RegistersResolverCorrectly() public {
        vm.startPrank(nameOwner);
        vm.roll(blocknumber); 
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        (address resolver, uint256 blockNumber, uint256 index) = registry.latestResolver(node);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockNumber, block.number);
        assertEq(index, 0);
    }

    function test_005____registerResolverUnauthorized_RevertsWhenUnauthorized() public {
        vm.startPrank(unauthorized);
        vm.roll(blocknumber); 
        vm.expectRevert(abi.encodeWithSelector(NotOwnerOrApprovedController.selector));
        registry.registerResolver(node);
    }

    function test_008____registerMultipleResolvers___RegistersAndRetrievesCorrectly() public {
        vm.startPrank(nameOwner);
        ens.setResolver(node, resolver);
        registry.registerResolver(node);

        // Advance block number and register second resolver
        vm.roll(blocknumber2);
        ens.setResolver(node, resolver2);
        registry.registerResolver(node);

        // Advance block number and register third resolver
        vm.roll(blocknumber3);
        ens.setResolver(node, resolver3);
        registry.registerResolver(node);

        // Check resolver at block time after the third registration
        (address resolvedAddress, ) = registry.getResolver(node, blocknumber3 + 1);
        assertEq(resolvedAddress, resolver3);

        // Check resolver between the second and third block time
        (resolvedAddress, ) = registry.getResolver(node, blocknumber2 + 50);
        assertEq(resolvedAddress, resolver2);

        // Check resolver exactly at the first block time
        (resolvedAddress, ) = registry.getResolver(node, blocknumber);
        assertEq(resolvedAddress, resolver);
    }

    function test_009____updateResolver______________UpdatesResolverCorrectly() public {
        vm.startPrank(nameOwner);
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        vm.stopPrank();

        // Update resolver as owner
        vm.startPrank(uResolverRegistryOwner);
        registry.updateResolver(node, 0, resolver2);
        vm.stopPrank();

        // Verify the resolver has been updated
        (address updatedResolver, , ) = registry.latestResolver(node);
        assertEq(updatedResolver, resolver2);
    }

    function test_010____updateResolverUnauthorized_RevertsWhenUnauthorized() public {
        vm.startPrank(nameOwner);
        ens.setResolver(node, resolver);
        registry.registerResolver(node);
        vm.stopPrank();

        // Attempt to update resolver as unauthorized user
        vm.startPrank(unauthorized);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, unauthorized));
        registry.updateResolver(node, 0, resolver3);
        vm.stopPrank();

        // Attempt to update resolver as name owner
        vm.startPrank(nameOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, nameOwner));
        registry.updateResolver(node, 0, resolver3);
        vm.stopPrank();
    }
} 