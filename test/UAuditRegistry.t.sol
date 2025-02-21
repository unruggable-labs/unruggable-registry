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

    function setUp() public {
        // Deploy the UAuditRegistry contract with the owner
        vm.startPrank(owner);
        auditRegistry = new UAuditRegistry(owner);
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
        vm.expectRevert(abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, unauthorized, auditRegistry.CONTROLLER_ROLE()));
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
} 