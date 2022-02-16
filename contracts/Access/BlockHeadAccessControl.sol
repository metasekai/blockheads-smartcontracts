// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract BlockHeadAccessControl is AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant CONTRACT_ROLE = keccak256("CONTRACT_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function hasPauserRole(address _account) public view returns (bool) {
        return hasRole(PAUSER_ROLE, _account);
    }

    function hasAdminRole(address _account) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _account);
    }

    function hasOperatorRole(address _account) public view returns (bool) {
        return hasRole(OPERATOR_ROLE, _account);
    }

    function hasContractRole(address _account) public view returns (bool) {
        return hasRole(CONTRACT_ROLE, _account);
    }

    function hasMinterRole(address _account) public view returns (bool) {
        return hasRole(MINTER_ROLE, _account);
    }

}