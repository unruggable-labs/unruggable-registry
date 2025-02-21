// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IUAuditRegistry.sol";

// Custom errors
error NotAnAuditor();

contract UAuditRegistry is IUAuditRegistry, AccessControl {
    // Role definition
    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");

    // Mapping for audit IDs
    mapping(address => uint256) private resolverAudits;

    constructor(address initialManager) {
        _grantRole(DEFAULT_ADMIN_ROLE, initialManager);
        _grantRole(CONTROLLER_ROLE, initialManager);
    }

    function setAuditId(address resolver, uint256 auditId) external override onlyRole(CONTROLLER_ROLE) {
        resolverAudits[resolver] = auditId;
    }

    function getAuditId(address resolver) external view override returns (uint256) {
        return resolverAudits[resolver];
    }
} 