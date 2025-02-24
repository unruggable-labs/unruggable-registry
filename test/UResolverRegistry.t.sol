// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {UResolverRegistry, NoResolverAtOrBeforeBlock, NotOwnerOrApprovedController, InvalidResolverIndex, NoResolversAvailable} from "../src/UResolverRegistry.sol";
import {DNSCoder} from "@unruggable-resolve/contracts/DNSCoder.sol";
import {BytesUtils} from "../src/utils/BytesUtils.sol";
import {ENSRegistry} from "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";

contract UResolverRegistryTest is Test {
    UResolverRegistry public registry;
    ENSRegistry public ensRegistry;
    address public fakeResolver;
    address public addr1 = address(1);
    address public addr2 = address(2);
    address public resolver = address(3);
    address public resolver2 = address(4);
    address public resolver3 = address(5);
    address public unauthorized = address(6);

    bytes32 nameEthNamehash;
    bytes32 ethNamehash;

    function setUp() public {

        // set addr1 as the msg.sender
        vm.startPrank(addr1);

         // set the time to now
        vm.warp(1000000);

        // deploy a ENS registry
        ensRegistry = new ENSRegistry();

        // deploy a UResolverRegistry
        registry = new UResolverRegistry(address(ensRegistry));

        // register the .eth subdomain
        ensRegistry.setSubnodeOwner(bytes32(0), keccak256(bytes("eth")), addr1);

        // create a namehash for name.eth
        ethNamehash = BytesUtils.namehash("\x03eth\x00", 0);

        // register name.eth
        ensRegistry.setSubnodeOwner(ethNamehash, keccak256(bytes("name")), addr1);

        // create a namehash for name.eth
        nameEthNamehash = BytesUtils.namehash("\x04name\x03eth\x00", 0);

        // check the ownership of name.eth
        address owner = ensRegistry.owner(nameEthNamehash);
        assertEq(owner, addr1, "name.eth should be owned by addr1");

    }

    function test1000________________________________________________________________________________() public {}
    function test2000__________________________URESOLVER_REGISTRY_____________________________________() public {}
    function test3000________________________________________________________________________________() public {}

    function test_001____RegisterResolver_____________RegistersResolver() public {

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        (address resolverCheck, ) = registry.latestResolver(nameEthNamehash);
        assertEq(resolverCheck, resolver, "Resolver should be registered");

        // move forward 100 seconds
        vm.warp(block.timestamp + 100);

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver2);

        // add resolver2 to registry
        registry.registerResolver(nameEthNamehash);

        // make sure the resolver is resolver2
        (address resolverCheck2, ) = registry.latestResolver(nameEthNamehash);
        assertEq(resolverCheck2, resolver2, "Resolver should be resolver2");

    }

    function test_002____getResolverInfoByIndex_______RegistersResolver() public {

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        (address resolverCheck, ) = registry.latestResolver(nameEthNamehash);
        assertEq(resolverCheck, resolver, "Resolver should be registered");

        // move forward 100 seconds
        vm.warp(block.timestamp + 100);

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver2);

        // add resolver2 to registry
        registry.registerResolver(nameEthNamehash);

        // make sure the resolver is resolver2
        (address resolverCheck2, ) = registry.latestResolver(nameEthNamehash);
        assertEq(resolverCheck2, resolver2, "Resolver should be resolver2");

        // get the resolver info by index
        (address resolverCheck3, ) = registry.getResolverInfoByIndex(nameEthNamehash, 0);
        assertEq(resolverCheck3, resolver, "Resolver should be resolver");

        // get the resolver info by index
        (address resolverCheck4, ) = registry.getResolverInfoByIndex(nameEthNamehash, 1);
        assertEq(resolverCheck4, resolver2, "Resolver should be resolver2");

    }

    // get the resovler by block time using the getResolver function using a block time
    function test_003____getResolver__________________GetResolverByBlockTime() public {

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        // move forward 100 seconds
        vm.warp(block.timestamp + 100);

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver2);

        // add resolver2 to registry
        registry.registerResolver(nameEthNamehash);

        // move forward 100 seconds
        vm.warp(block.timestamp + 100);

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver3);

        // add resolver3 to registry
        registry.registerResolver(nameEthNamehash);

        // make sure the resolver is resolver2
        (address resolverCheck2, ) = registry.latestResolver(nameEthNamehash); 
        assertEq(resolverCheck2, resolver3, "Resolver should be resolver3");

        // get the resolver info by index
        (address resolverCheck3, ) = registry.getResolverInfoByIndex(nameEthNamehash, 0);
        assertEq(resolverCheck3, resolver, "Resolver should be resolver");

        // get the resolver info by index
        (address resolverCheck4, ) = registry.getResolverInfoByIndex(nameEthNamehash, 1);
        assertEq(resolverCheck4, resolver2, "Resolver should be resolver2");

        // get the resolver info by index
        (address resolverCheck5, ) = registry.getResolverInfoByIndex(nameEthNamehash, 2);
        assertEq(resolverCheck5, resolver3, "Resolver should be resolver3");

        // get the resolver by block time
        (address resolverCheck6, ) = registry.getResolver(nameEthNamehash, uint64(block.timestamp - 150));
        assertEq(resolverCheck6, resolver, "Resolver should be resolver");

        // get the resolver by block time
        (address resolverCheck7, ) = registry.getResolver(nameEthNamehash, uint64(block.timestamp - 50));
        assertEq(resolverCheck7, resolver2, "Resolver should be resolver2");

        // get the resolver by block time
        (address resolverCheck8, ) = registry.getResolver(nameEthNamehash, uint64(block.timestamp + 50));
        assertEq(resolverCheck8, resolver3, "Resolver should be resolver3");

    }

    function test_004____registerResolver_____________RevertsWhenUnauthorized() public {

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver);

        vm.stopPrank();

        vm.startPrank(unauthorized);
        vm.warp(block.timestamp + 100); 
        vm.expectRevert(abi.encodeWithSelector(NotOwnerOrApprovedController.selector));
        registry.registerResolver(nameEthNamehash);
    }

    function test_005____RegisterResolver_____________RevertsWhenNoResolverAtOrBeforeBlock() public {

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, resolver);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        (address resolverCheck, ) = registry.latestResolver(nameEthNamehash);
        assertEq(resolverCheck, resolver, "Resolver should be registered");

        vm.expectRevert(abi.encodeWithSelector(NoResolverAtOrBeforeBlock.selector, 999999));
        registry.getResolver(nameEthNamehash, uint64(999999));

    }
    
    function test_006____latestResolver_______________RevertsWhenEmpty() public {
        vm.expectRevert(abi.encodeWithSelector(NoResolversAvailable.selector, nameEthNamehash));
        registry.latestResolver(nameEthNamehash);
    }

    function test_007____getResolverInfoByIndex_______RevertsOnInvalidIndex() public {
        // Register one resolver
        ensRegistry.setResolver(nameEthNamehash, resolver);
        registry.registerResolver(nameEthNamehash);
        
        // Try to access index 1 when only 0 exists
        vm.expectRevert(abi.encodeWithSelector(InvalidResolverIndex.selector, 1, 1));
        registry.getResolverInfoByIndex(nameEthNamehash, 1);
    }

    function test_008____registerResolver_____________HandlesZeroAddress() public {
        // Set resolver to zero address
        ensRegistry.setResolver(nameEthNamehash, address(0));
        
        // Should still register the zero address
        registry.registerResolver(nameEthNamehash);
        
        (address resolverAddr,) = registry.latestResolver(nameEthNamehash);
        assertEq(resolverAddr, address(0), "Should register zero address resolver");
    }

    function test_009____registerResolver_____________HandlesOwnershipChange() public {
        // Initial setup
        ensRegistry.setResolver(nameEthNamehash, resolver);
        registry.registerResolver(nameEthNamehash);
        
        // Transfer ownership to addr2
        ensRegistry.setOwner(nameEthNamehash, addr2);
        
        // Original owner should no longer be able to register
        vm.expectRevert(abi.encodeWithSelector(NotOwnerOrApprovedController.selector));
        registry.registerResolver(nameEthNamehash);
        
        // New owner should be able to register
        vm.stopPrank();
        vm.startPrank(addr2);
        ensRegistry.setResolver(nameEthNamehash, resolver2);
        registry.registerResolver(nameEthNamehash);
    }

    function test_010____registerResolver_____________WorksWithApprovedOperator() public {
        // Set up initial resolver
        ensRegistry.setResolver(nameEthNamehash, resolver);
        
        // Approve addr2 as operator
        ensRegistry.setApprovalForAll(addr2, true);
        
        // Switch to addr2 and verify they can register
        vm.stopPrank();
        vm.startPrank(addr2);
        registry.registerResolver(nameEthNamehash);
        
        (address resolverAddr,) = registry.latestResolver(nameEthNamehash);
        assertEq(resolverAddr, resolver, "Approved operator should be able to register resolver");
    }

    function test_011____getResolver__________________HandlesMultipleResolversInSameBlock() public {
        // Register multiple resolvers in the same block
        ensRegistry.setResolver(nameEthNamehash, resolver);
        registry.registerResolver(nameEthNamehash);
        
        ensRegistry.setResolver(nameEthNamehash, resolver2);
        registry.registerResolver(nameEthNamehash);
        
        // Should return the latest resolver for that block
        (address resolverAddr,) = registry.getResolver(nameEthNamehash, uint64(block.timestamp));
        assertEq(resolverAddr, resolver2, "Should return latest resolver in block");
    }

    function test_012____getResolver__________________HandlesExactBlockTimeMatch() public {
        uint64 timestamp1 = uint64(block.timestamp);
        ensRegistry.setResolver(nameEthNamehash, resolver);
        registry.registerResolver(nameEthNamehash);
        
        vm.warp(block.timestamp + 100);
        uint64 timestamp2 = uint64(block.timestamp);
        ensRegistry.setResolver(nameEthNamehash, resolver2);
        registry.registerResolver(nameEthNamehash);
        
        // Test exact timestamp matches
        (address resolverAddr1,) = registry.getResolver(nameEthNamehash, timestamp1);
        assertEq(resolverAddr1, resolver, "Should match exact first timestamp");
        
        (address resolverAddr2,) = registry.getResolver(nameEthNamehash, timestamp2);
        assertEq(resolverAddr2, resolver2, "Should match exact second timestamp");
    }

    function test_013____registerResolver_____________HandlesConsecutiveUpdates() public {
        // Register same resolver multiple times
        ensRegistry.setResolver(nameEthNamehash, resolver);
        registry.registerResolver(nameEthNamehash);
        registry.registerResolver(nameEthNamehash);
        
        // Verify history length and values
        (address resolver1,) = registry.getResolverInfoByIndex(nameEthNamehash, 0);
        (address resolver2,) = registry.getResolverInfoByIndex(nameEthNamehash, 1);
        
        assertEq(resolver1, resolver, "First registration should be recorded");
        assertEq(resolver2, resolver, "Second registration should be recorded");
    }

    function test_014____getResolver__________________HandlesBinarySearchEdgeCases() public {
        // Setup multiple resolvers at different times
        ensRegistry.setResolver(nameEthNamehash, resolver);
        registry.registerResolver(nameEthNamehash);
        
        vm.warp(block.timestamp + 100);
        ensRegistry.setResolver(nameEthNamehash, resolver2);
        registry.registerResolver(nameEthNamehash);
        
        vm.warp(block.timestamp + 100);
        ensRegistry.setResolver(nameEthNamehash, resolver3);
        registry.registerResolver(nameEthNamehash);
        
        // Test querying at exactly one timestamp before first entry
        uint64 beforeFirst = uint64(block.timestamp - 201);
        vm.expectRevert(abi.encodeWithSelector(NoResolverAtOrBeforeBlock.selector, beforeFirst));
        registry.getResolver(nameEthNamehash, beforeFirst);
        
        // Test querying at timestamp between entries
        (address midResolver,) = registry.getResolver(nameEthNamehash, uint64(block.timestamp - 50));
        assertEq(midResolver, resolver2, "Should return correct resolver for mid-point");
    }

    function test_015____registerResolver_____________HandlesMultipleNodes() public {
        bytes32 anotherNode = BytesUtils.namehash("\x05other\x03eth\x00", 0);
        
        // Set up another node
        ensRegistry.setSubnodeOwner(ethNamehash, keccak256(bytes("other")), addr1);
        
        // Set resolvers for both nodes
        ensRegistry.setResolver(nameEthNamehash, resolver);
        ensRegistry.setResolver(anotherNode, resolver2);
        
        // Register resolvers for both nodes
        registry.registerResolver(nameEthNamehash);
        registry.registerResolver(anotherNode);
        
        // Verify independent tracking
        (address resolver1,) = registry.latestResolver(nameEthNamehash);
        (address resolver2Addr,) = registry.latestResolver(anotherNode);
        
        assertEq(resolver1, resolver, "Should track first node's resolver");
        assertEq(resolver2Addr, resolver2, "Should track second node's resolver");
    }

    function test_016____registerResolver_____________HandlesLargeHistory() public {
        uint256 numUpdates = 10; // Adjust based on gas limits
        
        for(uint256 i = 0; i < numUpdates; i++) {
            vm.warp(block.timestamp + 100);
            ensRegistry.setResolver(nameEthNamehash, address(uint160(i + 100))); // Use different addresses
            registry.registerResolver(nameEthNamehash);
        }
        
        // Verify we can access all history points
        for(uint256 i = 0; i < numUpdates; i++) {
            (address resolverAddr,) = registry.getResolverInfoByIndex(nameEthNamehash, i);
            assertEq(resolverAddr, address(uint160(i + 100)), "Should maintain accurate history");
        }
    }

}
