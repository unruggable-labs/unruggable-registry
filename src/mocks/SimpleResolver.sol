// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IAddressResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddressResolver.sol";
import {IAddrResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IAddrResolver.sol";
import {ITextResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/ITextResolver.sol";
import {IContentHashResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IContentHashResolver.sol";
import {ENS} from "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import {IExtendedResolver} from "@ensdomains/ens-contracts/contracts/resolvers/profiles/IExtendedResolver.sol";

error Unauthorized();
error ResolveError(bytes);

contract SimpleResolver is Ownable, IAddressResolver, ITextResolver, IContentHashResolver, IExtendedResolver, IAddrResolver {

    ENS immutable ens;

    // Mappings for records
    mapping(bytes32 => mapping(uint256 => bytes)) private _addresses;
    mapping(bytes32 => mapping(string => string)) private _textRecords;
    mapping(bytes32 => bytes) private _contenthashes;

    constructor(ENS _ens, address initialOwner) Ownable(initialOwner) {
        ens = _ens;
    }

    modifier authorised(bytes32 node) {
        address owner = ens.owner(node);
        if(msg.sender != owner && !ens.isApprovedForAll(owner, msg.sender)) {
            revert Unauthorized();
        }
        _;
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == type(IAddressResolver).interfaceId ||
               interfaceID == type(IAddrResolver).interfaceId ||
               interfaceID == type(ITextResolver).interfaceId ||
               interfaceID == type(IContentHashResolver).interfaceId ||
               interfaceID == type(IExtendedResolver).interfaceId;
    }

    function resolve(bytes memory name, bytes memory data) external view returns (bytes memory) {
        // Extract the function select
        bytes4 selector;
        assembly {
            selector := mload(add(data, 32))
        }
        
        // Get namehash from data
        bytes32 node;
        assembly {
            node := mload(add(data, 36))
        }

        if (selector == IAddressResolver.addr.selector) {
            // Handle addr(bytes32,uint256)
            uint256 coinType;
            assembly {
                coinType := mload(add(data, 68))
            }
            return addr(node, coinType);
        } else if (selector == ITextResolver.text.selector) {
            // Handle text(bytes32,string)
            string memory key;
            assembly {
                key := add(data, 68)
            }
            return abi.encode(text(node, key));
        } else if (selector == IContentHashResolver.contenthash.selector) {
            // Handle contenthash(bytes32)
            return contenthash(node);
        }

        revert ResolveError(data);
    }

    function addr(bytes32 node) public view override returns (address payable) {
        return payable(address(uint160(uint256(bytes32(_addresses[node][60])))));
    }

    function addr(bytes32 node, uint256 coinType) public view override returns (bytes memory) {
        bytes memory addr = _addresses[node][coinType];
        if (addr.length == 0) {
            return "";
        }
        return addr;
    }

    function setAddr(bytes32 node, address addr) external authorised(node) {
        _addresses[node][60] = abi.encodePacked(addr);
        emit AddrChanged(node, addr);
    }

    function setAddr(bytes32 node, uint256 coinType, bytes memory addr) external authorised(node) {
        if (coinType == 60) {
            require(addr.length == 20, "Invalid address length");
            _addresses[node][coinType] = addr;
            emit AddressChanged(node, coinType, addr);
        } else {
            _addresses[node][coinType] = addr;
            emit AddressChanged(node, coinType, addr);
        }   

    }

    // Text records
    function text(bytes32 node, string memory key) public view override returns (string memory) {
        return _textRecords[node][key];
    }

    function setText(bytes32 node, string calldata key, string calldata value) external authorised(node) {
        _textRecords[node][key] = value;
        emit TextChanged(node, key, key, value);
    }

    // Content hash
    function contenthash(bytes32 node) public view override returns (bytes memory) {
        return _contenthashes[node];
    }

    function setContenthash(bytes32 node, bytes calldata hash) external authorised(node) {
        _contenthashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }
}