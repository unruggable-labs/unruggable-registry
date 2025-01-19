// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { URegistry } from "../src/URegistry.sol";
import { ENS } from "../src/ENS.sol";
import { MockENSRegistry } from "../src/MockENSRegistry.sol";
import { BytesUtils } from "../src/BytesUtils.sol";
// import custom errors
import { NoResolverBeforeBlock, NotOwnerOrApprovedController, NotAnAuditor } from "../src/URegistry.sol";

contract URegistryTest is Test {
    using BytesUtils for bytes;

    URegistry private registry;
    MockENSRegistry ens;
    address private ensOwner = address(0x1);
    address private nameOwner = address(0x1);
    address private auditor = address(0x2);
    address private unauthorized = address(0x3);
    address private resolver = address(0x4);

    // DNS-encoded name for "example.eth" using string literal format
    bytes private dnsEncodedName = "\x07example\x03eth\x00";

    // Compute the node hash using the namehash function
    bytes32 private node = dnsEncodedName.namehash(0);

    function setUp() public {

        vm.warp(1641070800); 
        vm.startPrank(ensOwner);
        
        ens = new MockENSRegistry(ensOwner);
        registry = new URegistry(address(ens));
        registry.grantRole(registry.AUDITOR_ROLE(), auditor);

        // Set initial resolver for the node in the mock registry
        ens.setOwner(node, nameOwner); // Example resolver address
        ens.setResolver(node, resolver); // Example resolver address

        vm.stopPrank();
    }

    function test1000________________________________________________________________________________() public {}
    function test2000__________________________UREGISTRY_FUNCTIONS____________________________________() public {}
    function test3000________________________________________________________________________________() public {}

    function test_001____getResolver_________________ReturnsCorrectResolver() public {
        vm.prank(nameOwner);
        registry.registerResolver(node);
        (address resolver, uint256 blockNumber) = registry.getResolver(node, block.number);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockNumber, block.number);
    }

    function test_002____getResolverNoRecord_________RevertsWhenNoRecord() public {
        vm.prank(nameOwner);
        vm.expectRevert(abi.encodeWithSelector(NoResolverBeforeBlock.selector, block.number));
        registry.getResolver(node, block.number);
    }

    function test_003____latestResolver______________ReturnsLatestResolver() public {
        vm.prank(nameOwner);
        registry.registerResolver(node);
        (address resolver, uint256 blockNumber) = registry.latestResolver(node);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockNumber, block.number);
    }

    function test_004____registerResolver____________RegistersResolverCorrectly() public {
        vm.prank(nameOwner);
        registry.registerResolver(node);
        (address resolver, uint256 blockNumber) = registry.latestResolver(node);
        assertEq(resolver, ens.resolver(node));
        assertEq(blockNumber, block.number);
    }

    function test_005____registerResolverUnauthorized_RevertsWhenUnauthorized() public {
        vm.prank(unauthorized);
        vm.expectRevert(abi.encodeWithSelector(NotOwnerOrApprovedController.selector));
        registry.registerResolver(node);
    }

    function test_006____setAuditId__________________SetsAuditIdCorrectly() public {
        vm.prank(auditor);
        registry.setAuditId(resolver, 1);
        assertEq(registry.getAuditId(resolver), 1);
    }

    function test_007____setAuditIdUnauthorized______RevertsWhenUnauthorized() public {
        vm.expectRevert(abi.encodeWithSelector(NotAnAuditor.selector));
        vm.prank(unauthorized);
        registry.setAuditId(address(ens), 1);
    }
}