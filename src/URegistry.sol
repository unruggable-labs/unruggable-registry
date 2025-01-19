// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/access/AccessControl.sol";
import "./ENS.sol";
// console log
import "forge-std/console.sol";

// Custom errors
error NoResolverAtOrBeforeBlock(uint256 blockNumber);
error NotOwnerOrApprovedController();
error NotAnAuditor();

contract URegistry is AccessControl {
    struct ResolverInfo {
        address resolver;
        uint256 blockNumber;
    }

    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    mapping(bytes32 => ResolverInfo[]) private resolvers;

    // New mapping for audit IDs
    mapping(address => uint256) private resolverAudits;

    ENS public ensRegistry;

    constructor(address _ensRegistry) {
        ensRegistry = ENS(_ensRegistry);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AUDITOR_ROLE, msg.sender);
    }
    
    // Resolver at or before the block number
    function getResolver(bytes32 node, uint256 blockNumber) external view returns (address, uint256) {

        // Use a binary search to find the resolver at or before the block number
        ResolverInfo[] storage resolverList = resolvers[node];
        uint256 low = 0;
        uint256 high = resolverList.length;

        while (low < high) {
            uint256 mid = (low + high) / 2;
            if (resolverList[mid].blockNumber <= blockNumber) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }

        if (low == 0) {
            revert NoResolverAtOrBeforeBlock(blockNumber);
        }

        ResolverInfo storage result = resolverList[low - 1];
        return (result.resolver, result.blockNumber);
    }

    // Latest resolver
    function latestResolver(bytes32 node) external view returns (address, uint256) {
        return (resolvers[node][resolvers[node].length - 1].resolver, resolvers[node][resolvers[node].length - 1].blockNumber);
    }

    function registerResolver(bytes32 node) external {
        address nodeOwner = ensRegistry.owner(node);
        if (!(msg.sender == nodeOwner || ensRegistry.isApprovedForAll(nodeOwner, msg.sender))) {
            revert NotOwnerOrApprovedController();
        }

        address resolverAddress = ensRegistry.resolver(node);
        
        // Create a new ResolverInfo struct
        ResolverInfo memory newInfo;
        newInfo.resolver = resolverAddress;
        newInfo.blockNumber = block.number;

        // Push the new ResolverInfo onto the array for the node
        resolvers[node].push(newInfo);
    }

    function setAuditId(address resolver, uint256 auditId) external {
        if (!hasRole(AUDITOR_ROLE, msg.sender)) {
            revert NotAnAuditor();
        }
        resolverAudits[resolver] = auditId;
    }

    function getResolverInfo(bytes32 node, uint256 index) external view returns (address, uint256) {
        ResolverInfo storage info = resolvers[node][index];
        return (info.resolver, info.blockNumber);
    }

    function getAuditId(address resolver) external view returns (uint256) {
        return resolverAudits[resolver];
    }

    function getResolverLatest(bytes32 node) external view returns (address, uint256) {
        require(resolvers[node].length > 0, "No resolvers available for this node");
        ResolverInfo storage latestResolver = resolverList[resolvers[node].length - 1];
        return (latestResolver.resolver, latestResolver.blockNumber);
    }
}
