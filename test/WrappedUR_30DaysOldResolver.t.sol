// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {UResolverRegistry, IUResolverRegistry, NoResolverAtOrBeforeBlock, NotOwnerOrApprovedController} from "../src/UResolverRegistry.sol";
import {DNSCoder} from "@unruggable-resolve/contracts/DNSCoder.sol";
import {UR, IUR} from "@unruggable-resolve/contracts/UR.sol";
import {WrappedUR_30DaysOldResolver, ResolverTooNew} from "../src/wrappers/WrappedUR_30DaysOldResolver.sol";
import {Lookup, Response} from "@unruggable-resolve/contracts/IUR.sol";
import {SimpleResolver} from "../src/mocks/SimpleResolver.sol";
import {ENS} from "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddressResolver.sol";

import {BytesUtils} from "../src/utils/BytesUtils.sol";
import {ENSRegistry} from "@ensdomains/ens-contracts/contracts/registry/ENSRegistry.sol";


contract WrappedUR_30DaysOldResolverTest is Test {
    IUResolverRegistry public registry;
    ENSRegistry public ensRegistry;
    IUR public ur;
    WrappedUR_30DaysOldResolver public wrappedUR;
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
        wrappedUR = new WrappedUR_30DaysOldResolver(ur, registry);

        // deploy a simple resolver
        simpleResolver = new SimpleResolver(ENS(address(ensRegistry)), addr1);

        // set the resolver for name.eth
        ensRegistry.setResolver(nameEthNamehash, address(simpleResolver));

        // set the address for Ethereum Mainnet
        simpleResolver.setAddr(nameEthNamehash, 60, abi.encodePacked(addr1));

    }

    function test1000________________________________________________________________________________() public {}
    function test2000______________________WRAPPED_UR_30_DAYS_OLD_RESOLVER___________________________() public {}
    function test3000________________________________________________________________________________() public {}

    function test_001____Resolve______________________ResolveAnAddress() public {

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        // move forward by 30 days + 1 second
        vm.warp(block.timestamp + 30 days);

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
    }

    function test_001____Resolve______________________CannotResolveAnAddressOfARecentlyRegisteredResolver() public {

        // add resolver to registry
        registry.registerResolver(nameEthNamehash);

        // move forward by 30 days + 1 second
        vm.warp(block.timestamp + 29 days );

        // encode a addr call with coinType 60
        bytes memory addrCall = abi.encodeCall(IAddressResolver.addr, (nameEthNamehash, 60));

        // create a length 1 array of the addr call
        bytes[] memory calls = new bytes[](1);

        // set the first element of the calls array to the addr call
        calls[0] = addrCall;

        // expect the resolve to revert
        vm.expectRevert(abi.encodeWithSelector(ResolverTooNew.selector));
        // resolve name.eth using wrappedUR
        (Lookup memory lookup, Response[] memory res) = wrappedUR.resolve("\x04name\x03eth\x00", calls, new string[](0));

    }
}
