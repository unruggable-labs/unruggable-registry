// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IUAuditRegistry {
    /**
     * @notice Sets the audit ID for a resolver
     * @param resolver The address of the resolver
     * @param auditId The audit ID to set
     */
    function setAuditId(address resolver, uint256 auditId) external;

    /**
     * @notice Gets the audit ID for a resolver
     * @param resolver The address of the resolver
     * @return The audit ID for the resolver
     */
    function getAuditId(address resolver) external view returns (uint256);

} 