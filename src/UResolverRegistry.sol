// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/access/Ownable.sol";
import "./ENS.sol";
// console log
import "forge-std/console.sol";

// Custom errors
error NoResolverAtOrBeforeBlock(uint256 blockNumber);
error NotOwnerOrApprovedController();

contract UResolverRegistry is Ownable {
    struct ResolverInfo {
        address resolver;
        uint256 blockNumber;
    }

    mapping(bytes32 => ResolverInfo[]) internal resolvers;

    ENS public ensRegistry;

    constructor(address _ensRegistry) Ownable(msg.sender) {
        ensRegistry = ENS(_ensRegistry);
    }
    
    // Resolver at or before the block number
    function getResolver(bytes32 node, uint256 blockNumber) external view returns (address /*resolver*/, uint256 /*blockNumber*/) {

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

    function getResolverInfoByIndex(bytes32 node, uint256 index) external view returns (address /*resolver*/, uint256 /*blockNumber*/) {
        ResolverInfo storage info = resolvers[node][index];
        return (info.resolver, info.blockNumber);
    }

    function latestResolver(bytes32 node) external view returns (address /*resolver*/, uint256 /*blockNumber*/, uint256 /*index*/) {

        // get the length of the resolver list
        uint256 length = resolvers[node].length;

        // check if the length is greater than 0
        require(length > 0, "No resolvers available for this node");

        // return the resolver and block number of the latest resolver
        return (resolvers[node][length - 1].resolver, resolvers[node][length - 1].blockNumber, length-1);
    }

} 