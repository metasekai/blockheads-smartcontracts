// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../Access/BlockHeadAccessControl.sol";

contract BlockHeads is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Pausable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    BlockHeadAccessControl public accessControl;

    string public baseURI = "";

    event NewBlockHeadCreated(address indexed owner, uint256 indexed tokenId);

    /**
     * @dev Allow only admin role to operate on certain functions
     */
    modifier onlyAdmin() {
        require(
            accessControl.hasAdminRole(msg.sender), 
            "BlockHead: Only admin can perform this action"
        );
        _;
    }
    

    constructor(
        address _accessControl
    ) ERC721("BlockHead", "BlockHeads") {
        accessControl = BlockHeadAccessControl(_accessControl);

        _tokenIdCounter.increment();
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // function safeMint(address to, string memory uri) public onlyRole(MINTER_ROLE) {
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _safeMint(to, tokenId);
    //     _setTokenURI(tokenId, uri);
    // }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function pause() public {
        require(
            accessControl.hasPauserRole(msg.sender), 
            "BlockHeads: Only pauser role can pause the contract"
        );
        _pause();
    }

    function unpause() public {
        require(
            accessControl.hasPauserRole(msg.sender), 
            "BlockHeads: Only pauser role can unpause the contract"
        );
        _unpause();
    }

    function setBaseURI(string memory _uri) public onlyAdmin {
        baseURI = _uri;
    }

    function createBlockHeads(address to, uint256 qty) public returns (bool) {
        require(
            accessControl.hasMinterRole(msg.sender),
            "BlockHeads: Only minter role can mint new BlockHeads"
        );

        // Mint multiple BlockHeads
        for (uint i = 0; i < qty; i++) {
            _mintNewBlockHead(to);
        }

        return true;
    }

    function _mintNewBlockHead(address to) private {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        emit NewBlockHeadCreated(to, tokenId);
    }
}