// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { UAuditRegistry } from "../src/UAuditRegistry.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

contract UAuditRegistryTest is Test {
    UAuditRegistry private auditRegistry;
    address private owner = address(0x1);
    address private auditor = address(0x2);
    address private unauthorized = address(0x3);

    // Resolver addresses
    address private resolver = address(0x4);
    address private resolver2 = address(0x5);

    // Role variables
    bytes32 private defaultAdminRole;

    function setUp() public {
        // Deploy the UAuditRegistry contract with the owner
        vm.startPrank(owner);
        auditRegistry = new UAuditRegistry(owner);
        defaultAdminRole = auditRegistry.DEFAULT_ADMIN_ROLE();
        vm.stopPrank();
    }

    function test1000________________________________________________________________________________() public {}
    function test2000__________________________UAUDIT_REGISTRY_______________________________________() public {}
    function test3000________________________________________________________________________________() public {}

    function test_001____setAuditId__________________SetsAuditIdCorrectly() public {
        vm.startPrank(owner);
        auditRegistry.setAuditId(resolver, 1);
        assertEq(auditRegistry.getAuditId(resolver), 1);
        vm.stopPrank();
    }

    function test_002____setAuditIdUnauthorized______RevertsWhenUnauthorized() public {
        vm.startPrank(unauthorized);
        bytes32 controllerRole = auditRegistry.CONTROLLER_ROLE();
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorized, controllerRole));
        auditRegistry.setAuditId(resolver, 1);
        vm.stopPrank();
    }

    function test_003____getAuditId__________________ReturnsCorrectAuditId() public {
        vm.startPrank(owner);
        auditRegistry.setAuditId(resolver, 1);
        auditRegistry.setAuditId(resolver2, 2);
        vm.stopPrank();

        assertEq(auditRegistry.getAuditId(resolver), 1);
        assertEq(auditRegistry.getAuditId(resolver2), 2);
    }

    function test_004____hasRole_____________________OwnerHasControllerRole() public {
        assertTrue(auditRegistry.hasRole(auditRegistry.CONTROLLER_ROLE(), owner));
    }

    function test_005____hasRole_____________________OwnerHasDefaultAdminRole() public {
        assertTrue(auditRegistry.hasRole(auditRegistry.DEFAULT_ADMIN_ROLE(), owner));
    }

    function test_006____setAuditId____________________SetsAuditIdToZero() public {
        vm.startPrank(owner);
        auditRegistry.setAuditId(resolver, 0);
        assertEq(auditRegistry.getAuditId(resolver), 0);
        vm.stopPrank();
    }

    function test_007____setAuditId____________________OverwritesExistingAuditId() public {
        vm.startPrank(owner);
        auditRegistry.setAuditId(resolver, 1);
        auditRegistry.setAuditId(resolver, 2);
        assertEq(auditRegistry.getAuditId(resolver), 2);
        vm.stopPrank();
    }

    function test_008____getAuditId____________________ReturnsZeroForUnsetResolver() public {
        assertEq(auditRegistry.getAuditId(address(0x6)), 0);
    }

    function test_009____grantRole_____________________OwnerCanGrantRole() public {
        vm.startPrank(owner);
        auditRegistry.grantRole(auditRegistry.CONTROLLER_ROLE(), auditor);
        assertTrue(auditRegistry.hasRole(auditRegistry.CONTROLLER_ROLE(), auditor));
        vm.stopPrank();
    }

    function test_010____revokeRole____________________OwnerCanRevokeRole() public {
        vm.startPrank(owner);
        auditRegistry.grantRole(auditRegistry.CONTROLLER_ROLE(), auditor);
        auditRegistry.revokeRole(auditRegistry.CONTROLLER_ROLE(), auditor);
        assertFalse(auditRegistry.hasRole(auditRegistry.CONTROLLER_ROLE(), auditor));
        vm.stopPrank();
    }

    function test_011____grantRole_____________________RevertsWhenUnauthorized() public {
        vm.startPrank(unauthorized);
        bytes32 controllerRole = auditRegistry.CONTROLLER_ROLE();
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorized, defaultAdminRole));
        auditRegistry.grantRole(controllerRole, unauthorized);
        vm.stopPrank();
    }

    function test_012____revokeRole____________________RevertsWhenUnauthorized() public {
        vm.startPrank(unauthorized);
        bytes32 controllerRole = auditRegistry.CONTROLLER_ROLE();
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorized, defaultAdminRole));
        auditRegistry.revokeRole(controllerRole, owner);
        vm.stopPrank();
    }
} 