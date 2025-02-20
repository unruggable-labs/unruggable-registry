// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/access/AccessControl.sol";
import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import "./IUResolverRegistry.sol";

contract UResolverRegistry is IUResolverRegistry, AccessControl {
    struct ResolverInfo {
        address resolver;
        uint64 blockTime;
    }

    mapping(bytes32 => ResolverInfo[]) private resolvers;

    ENS public ensRegistry;

    constructor(address _ensRegistry) {
        ensRegistry = ENS(_ensRegistry);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function getResolver(bytes32 node, uint64 blockTime) external view returns (address, uint64) {
        ResolverInfo[] storage resolverList = resolvers[node];
        uint256 low = 0;
        uint256 high = resolverList.length;

        while (low < high) {
            uint256 mid = (low + high) / 2;
            if (resolverList[mid].blockTime <= blockTime) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }

        if (low == 0) {
            revert NoResolverAtOrBeforeBlock(blockTime);
        }

        ResolverInfo storage result = resolverList[low - 1];
        return (result.resolver, result.blockTime);
    }

    function registerResolver(bytes32 node) external {
        address nodeOwner = ensRegistry.owner(node);
        if (!(msg.sender == nodeOwner || ensRegistry.isApprovedForAll(nodeOwner, msg.sender))) {
            revert NotOwnerOrApprovedController();
        }

        address resolverAddress = ensRegistry.resolver(node);
        
        ResolverInfo memory newInfo;
        newInfo.resolver = resolverAddress;
        newInfo.blockTime = uint64(block.timestamp);

        resolvers[node].push(newInfo);
    }

    function getResolverInfoByIndex(bytes32 node, uint256 index) external view returns (address /*resolver*/, uint64 /*blockTime*/) {
        ResolverInfo storage info = resolvers[node][index];
        return (info.resolver, info.blockTime);
    }

    function latestResolver(bytes32 node) external view returns (address, uint64) {
        ResolverInfo[] storage resolverList = resolvers[node];
        require(resolverList.length > 0, "No resolvers available for this node");

        ResolverInfo storage latestResolver = resolverList[resolverList.length - 1];
        return (latestResolver.resolver, latestResolver.blockTime);
    }
} 