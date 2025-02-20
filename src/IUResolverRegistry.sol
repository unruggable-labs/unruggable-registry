// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@ensdomains/ens-contracts/contracts/registry/ENS.sol";

// Custom errors
error NoResolverAtOrBeforeBlock(uint256 blockTime);
error NotOwnerOrApprovedController();

interface IUResolverRegistry {
    /** @notice Get the resolver at or before a specific block time
     * @param node The namehash of the ENS name
     * @param blockTime The block time to query
     * @return The resolver address and the block time it was set
     */
    function getResolver(bytes32 node, uint64 blockTime) external view returns (address, uint64);

    /** @notice Register a resolver for a node
     * @param node The namehash of the ENS name
     */
    function registerResolver(bytes32 node) external;

    /** @notice Get resolver info at a specific index
     * @param node The namehash of the ENS name
     * @param index The index in the resolver array
     * @return The resolver address and the block time it was set
     */
    function getResolverInfoByIndex(bytes32 node, uint256 index) external view returns (address /*resolver*/, uint64 /*blockTime*/);

    /** @notice Get the latest resolver for a node
     * @param node The namehash of the ENS name
     * @return The resolver address and the block time it was set
     */
    function latestResolver(bytes32 node) external view returns (address, uint64);

    /** @notice Get the ENS registry address
     * @return The ENS registry address
     */
    function ensRegistry() external view returns (ENS);
} 