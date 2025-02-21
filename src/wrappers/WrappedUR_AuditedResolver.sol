// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// provided as an example for how to wrap the UR

import {CCIPReader} from "@unruggable/CCIPReader.sol/contracts/CCIPReader.sol";
import {IUR, Lookup, Response} from "@unruggable-resolve/contracts/IUR.sol";
import {IUResolverRegistry} from "../IUResolverRegistry.sol";
import {console} from "forge-std/console.sol";
import {IUAuditRegistry} from "../IUAuditRegistry.sol";

error ResolverNotAudited();

contract WrappedUR_AuditedResolver is CCIPReader {
    IUR public immutable ur;
    IUAuditRegistry public immutable auditRegistry;

    constructor(IUR _ur, IUAuditRegistry _auditRegistry) {
        ur = _ur;
        auditRegistry = _auditRegistry;
    }

    function resolve(bytes memory dns, bytes[] memory calls, string[] memory gateways)
        external
        view
        returns (Lookup memory lookup, Response[] memory res)
    {
        lookup = ur.lookupName(dns);
        if (lookup.resolver == address(0)) return (lookup, res);

        // Check if the resolver has a valid audit ID (greater than 0)
        uint256 auditId = auditRegistry.getAuditId(lookup.resolver);
        if (auditId == 0) {
            revert ResolverNotAudited();
        }

        bytes memory v = ccipRead(
            address(ur), abi.encodeCall(IUR.resolve, (dns, calls, gateways)), this.resolveCallback.selector, ""
        );
        assembly {
            return(add(v, 32), mload(v))
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
