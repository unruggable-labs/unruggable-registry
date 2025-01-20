// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/access/Ownable.sol";

// Custom errors
error NotAnAuditor();

contract UAuditRegistry is Ownable {
    // Mapping for audit IDs
    mapping(address => uint256) private resolverAudits;

    constructor(address _owner) Ownable(_owner) {}

    function setAuditId(address resolver, uint256 auditId) external onlyOwner {
        resolverAudits[resolver] = auditId;
    }

    function getAuditId(address resolver) external view returns (uint256) {
        return resolverAudits[resolver];
    }
} 