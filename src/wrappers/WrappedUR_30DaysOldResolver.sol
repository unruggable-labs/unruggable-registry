// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// provided as an example for how to wrap the UR

import {CCIPReader} from "@unruggable/CCIPReader.sol/contracts/CCIPReader.sol";
import {IUR, Lookup, Response} from "@unruggable-resolve/contracts/IUR.sol";
import {IUResolverRegistry} from "../IUResolverRegistry.sol";
import {console} from "forge-std/console.sol";

error ResolverNotRegistered();
error ResolverTooNew();

contract WrappedUR_30DaysOldResolver is CCIPReader {
    IUR public immutable ur;
    IUResolverRegistry public immutable registry;

    constructor(IUR _ur, IUResolverRegistry _registry) {
        ur = _ur;
        registry = _registry;
    }

    function resolve(bytes memory dns, bytes[] memory calls, string[] memory gateways)
        external
        view
        returns (Lookup memory lookup, Response[] memory res)
    {
        lookup = ur.lookupName(dns);
        if (lookup.resolver == address(0)) return (lookup, res);

        // get the latest resolver for the node
        (address resolver, uint64 blockTime) = _getLatestResolver(lookup.node);

        // if the resolver is not the latest resolver, or it's not at least 30 days old, revert
        if (resolver != lookup.resolver) {
            revert ResolverNotRegistered();
        }

        // if the resolver is not at least 30 days old, revert
        if (blockTime > block.timestamp - 30 days) {
            revert ResolverTooNew();
        }

        bytes memory v = ccipRead(
            address(ur), abi.encodeCall(IUR.resolve, (dns, calls, gateways)), this.resolveCallback.selector, ""
        );
        assembly {
            return(add(v, 32), mload(v))
        }
    }

    function _getLatestResolver(bytes32 node) internal view returns (address resolver, uint64 blockTime) {
        try registry.latestResolver(node) returns (address r, uint64 t) {
            resolver = r;
            blockTime = t;
        } catch {
            revert ResolverNotRegistered();
        }
    }

    function resolveCallback(bytes memory ccip, bytes calldata)
        external
        pure
        returns (Lookup memory, Response[] memory)
    {
        assembly {
            return(add(ccip, 32), mload(ccip)) // exact same return as UR
        }
    }
}
