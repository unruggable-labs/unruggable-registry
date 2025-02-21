// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {UResolverRegistry, NoResolverAtOrBeforeBlock, NotOwnerOrApprovedController} from "../src/UResolverRegistry.sol";
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
    

}
