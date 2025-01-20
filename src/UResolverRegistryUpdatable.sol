// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./UResolverRegistry.sol";


contract UResolverRegistryUpdatable is UResolverRegistry {

    constructor(address ensRegistry) UResolverRegistry(ensRegistry) {}

    // In emergencies, the owner of this contract can change the resolver of a node at any index, but not the block number. 
    function updateResolver(bytes32 node, uint256 index, address newResolver) external onlyOwner {
        // change the resolver in the parent contract
        UResolverRegistry.resolvers[node][index].resolver = newResolver;
    }

} 