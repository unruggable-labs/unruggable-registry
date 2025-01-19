// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/access/AccessControl.sol";
import "./ENS.sol";

// Custom errors
error NoResolverBeforeBlock(uint256 blockNumber);
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

        // find the resolver record at or before the block number
        for (uint256 i = resolvers[node].length; i > 0; i--) {
            if (resolvers[node][i-1].blockNumber <= blockNumber) {
                return (resolvers[node][i-1].resolver, resolvers[node][i-1].blockNumber);
            }
        }
        revert NoResolverBeforeBlock(blockNumber);
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
}
