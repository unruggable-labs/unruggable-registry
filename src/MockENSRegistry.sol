// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./ENS.sol";
import "@openzeppelin/access/Ownable.sol";

contract MockENSRegistry is ENS, Ownable {

    mapping(bytes32 => address) private _resolvers;
    mapping(bytes32 => address) private _owners;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(bytes32 => uint64) private _ttls;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setResolver(bytes32 node, address resolverAddress) external {
        require(msg.sender == _owners[node], "Caller is not the owner of the node");
        _resolvers[node] = resolverAddress;
    }

    function setOwner(bytes32 node, address newOwner) external onlyOwner {
        _owners[node] = newOwner;
    }

    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
    }

    function resolver(bytes32 node) external view override returns (address) {
        return _resolvers[node];
    }

    function owner(bytes32 node) external view override returns (address) {
        return _owners[node];
    }

    function isApprovedForAll(address ownerAddress, address operator) external view override returns (bool) {
        return _operatorApprovals[ownerAddress][operator];
    }

    // Implement remaining ENS interface functions
    function setRecord(bytes32 node, address ownerAddress, address resolverAddress, uint64 ttl) external override {
        _owners[node] = ownerAddress;
        _resolvers[node] = resolverAddress;
        _ttls[node] = ttl;
    }

    function setSubnodeRecord(bytes32 node, bytes32 label, address ownerAddress, address resolverAddress, uint64 ttl) external override {
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        _owners[subnode] = ownerAddress;
        _resolvers[subnode] = resolverAddress;
        _ttls[subnode] = ttl;
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address ownerAddress) external override returns(bytes32) {
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        _owners[subnode] = ownerAddress;
        return subnode;
    }

    function setTTL(bytes32 node, uint64 ttl) external override {
        require(msg.sender == _owners[node], "Caller is not the owner of the node");
        _ttls[node] = ttl;
    }

    function ttl(bytes32 node) external view override returns (uint64) {
        return _ttls[node];
    }

    function recordExists(bytes32 node) external view override returns (bool) {
        return _owners[node] != address(0);
    }
}