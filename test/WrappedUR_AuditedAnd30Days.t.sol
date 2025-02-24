// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {UResolverRegistry, IUResolverRegistry, NoResolverAtOrBeforeBlock, NotOwnerOrApprovedController} from "../src/UResolverRegistry.sol";
import {DNSCoder} from "@unruggable-resolve/contracts/DNSCoder.sol";
import {UR, IUR} from "@unruggable-resolve/contracts/UR.sol";
import {WrappedUR_AuditedAnd30Days, ResolverTooNew, ResolverNotAudited, ResolverNotRegistered} from "../src/wrappers/WrappedUR_AuditedAnd30Days.sol";
import {Lookup, Response} from "@unruggable-resolve/contracts/IUR.sol";
import {SimpleResolver} from "../src/mocks/SimpleResolver.sol";
import {ENS} from "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddressResolver.sol";
import {UAuditRegistry} from "../src/UAuditRegistry.sol";
import {BytesUtils} from "../src/utils/BytesUtils.sol";
import {ENSRegistry} from "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";

contract WrappedUR_AuditedAnd30DaysTest is Test {
    IUResolverRegistry public registry;
    UAuditRegistry public auditRegistry;
    ENSRegistry public ensRegistry;
    IUR public ur;
    WrappedUR_AuditedAnd30Days public wrappedUR;
    SimpleResolver public simpleResolver;

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

        // deploy a UR with no gateways
        ur = new UR(address(ensRegistry), new string[](0));

        // deploy a UResolverRegistry
        registry = new UResolverRegistry(address(ensRegistry));

        // deploy the audit registry
        auditRegistry = new UAuditRegistry(addr1);

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

        // deploy a wrapped UR
        wrappedUR = new WrappedUR_AuditedAnd30Days(ur, registry, auditRegistry);

        // deploy a simple resolver
        simpleResolver = new SimpleResolver(ENS(address(ensRegistry)), addr1);

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, address(simpleResolver));

        // set the address for Ethereum Mainnet
        simpleResolver.setAddr(nameEthNamehash, 60, abi.encodePacked(addr1));

        vm.stopPrank();
    }

    function test1000________________________________________________________________________________() public {}
    function test2000______________________WRAPPED_UR_AUDITED_AND_30_DAYS____________________________() public {}
    function test3000________________________________________________________________________________() public {}

    function test_001____Resolve______________________ResolveAnAddress() public {
        vm.startPrank(addr1);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        // set audit ID for the resolver
        auditRegistry.setAuditId(address(simpleResolver), 1);

        // move forward by 30 days + 1 second
        vm.warp(block.timestamp + 30 days + 1);

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));

        // create a length 1 array of the addr call
        bytes[] memory calls = new bytes[](1);

        // set the first element of the calls array to the addr call
        calls[0] = addrCall;

        // resolve name.eth using wrappedUR
        (Lookup memory lookup, Response[] memory res) = wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));

        // make sure the resolved address is addr1
        assertEq(res[0].data, abi.encodePacked(addr1), "Resolved address should be addr1");
        vm.stopPrank();
    }

    function test_002____Resolve______________________CannotResolveAnAddressOfUnauditedResolver() public {
        vm.startPrank(addr1);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        // move forward by 30 days + 1 second
        vm.warp(block.timestamp + 30 days + 1);

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));

        // create a length 1 array of the addr call
        bytes[] memory calls = new bytes[](1);

        // set the first element of the calls array to the addr call
        calls[0] = addrCall;

        // expect the resolve to revert because resolver has no audit ID
        vm.expectRevert(ResolverNotAudited.selector);
        wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));
        vm.stopPrank();
    }

    function test_003____Resolve______________________CannotResolveAnAddressOfARecentlyRegisteredResolver() public {
        vm.startPrank(addr1);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        // set audit ID for the resolver
        auditRegistry.setAuditId(address(simpleResolver), 1);

        // move forward by less than 29 days
        vm.warp(block.timestamp + 29 days);

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));

        // create a length 1 array of the addr call
        bytes[] memory calls = new bytes[](1);

        // set the first element of the calls array to the addr call
        calls[0] = addrCall;

        // expect the resolve to revert
        vm.expectRevert(ResolverTooNew.selector);
        wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));
        vm.stopPrank();
    }

    function test_004____Resolve______________________CannotResolveWithZeroAuditId() public {
        vm.startPrank(addr1);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        // set audit ID for the resolver to 0
        auditRegistry.setAuditId(address(simpleResolver), 0);

        // move forward by 30 days + 1 second
        vm.warp(block.timestamp + 30 days + 1);

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));

        // create a length 1 array of the addr call
        bytes[] memory calls = new bytes[](1);

        // set the first element of the calls array to the addr call
        calls[0] = addrCall;

        // expect the resolve to revert because audit ID is 0
        vm.expectRevert(ResolverNotAudited.selector);
        wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));
        vm.stopPrank();
    }

    function test_005____Resolve______________________ResolveWithZeroResolver() public {
        vm.startPrank(addr1);

        // Create a new subdomain that will have no resolver
        bytes32 emptyNode = BytesUtils.namehash("\x05empty\x03eth\x00", 0);
        ensRegistry.setSubnodeOwner(ethNamehash, keccak256(bytes("empty")), addr1);

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (emptyNode, 60));
        bytes[] memory calls = new bytes[](1);
        calls[0] = addrCall;

        // resolve should return empty results without reverting
        (Lookup memory lookup, Response[] memory res) = wrappedUR.resolve("\x05empty\x03eth\x00", calls, new string[](0));
        assertEq(lookup.resolver, address(0), "Resolver should be zero address");
        assertEq(res.length, 0, "Response array should be empty");
        vm.stopPrank();
    }

    function test_006____Resolve______________________ResolveWithMismatchedResolver() public {
        vm.startPrank(addr1);

        // Deploy a second resolver
        SimpleResolver differentResolver = new SimpleResolver(ENS(address(ensRegistry)), addr1);

        // Register the original resolver in the registry
        registry.registerResolver(nameEthNamehash);
        
        // Set audit ID for both resolvers
        auditRegistry.setAuditId(address(simpleResolver), 1);
        auditRegistry.setAuditId(address(differentResolver), 1);
        
        vm.warp(block.timestamp + 30 days + 1);

        // But set a different resolver in ENS
        ensRegistry.setResolver(nameEthNamehash, address(differentResolver));

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));
        bytes[] memory calls = new bytes[](1);
        calls[0] = addrCall;

        // expect revert because resolver mismatch
        vm.expectRevert(ResolverNotRegistered.selector);
        wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));
        vm.stopPrank();
    }

    function test_007____Resolve______________________ResolveWithMultipleCalls() public {
        vm.startPrank(addr1);

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);
        auditRegistry.setAuditId(address(simpleResolver), 1);
        vm.warp(block.timestamp + 30 days + 1);

        // Set addresses for multiple coin types
        simpleResolver.setAddr(nameEthNamehash, 60, abi.encodePacked(addr1));  // ETH
        simpleResolver.setAddr(nameEthNamehash, 0, abi.encodePacked(addr2));   // BTC
        
        // Create multiple calls for different coin types
        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));
        calls[1] = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 0));

        // resolve name.eth using wrappedUR
        (Lookup memory lookup, Response[] memory res) = wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));

        // verify both responses
        assertEq(res.length, 2, "Should have two responses");
        assertEq(res[0].data, abi.encodePacked(addr1), "First response should be ETH address");
        assertEq(res[1].data, abi.encodePacked(addr2), "Second response should be BTC address");
        vm.stopPrank();
    }

    function test_008____Resolve______________________ResolveWithUnregisteredResolver() public {
        vm.startPrank(addr1);

        // Set resolver in ENS but don't register it in registry
        ensRegistry.setResolver(nameEthNamehash, address(simpleResolver));
        
        // Set audit ID (even though not registered)
        auditRegistry.setAuditId(address(simpleResolver), 1);
        vm.warp(block.timestamp + 30 days + 1);

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));
        bytes[] memory calls = new bytes[](1);
        calls[0] = addrCall;

        // expect revert because no resolvers are available
        vm.expectRevert(abi.encodeWithSignature("NoResolversAvailable(bytes32)", nameEthNamehash));
        wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));
        vm.stopPrank();
    }
} 