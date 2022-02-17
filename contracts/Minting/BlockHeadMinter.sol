// SPDX-License-Identifier: MIT
/**
 * @author Alleo Indong
 */
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../Access/BlockHeadAccessControl.sol";
import "../NFT/BlockHeads.sol";

contract BlockHeadMinter is Pausable {
    BlockHeadAccessControl public accessControl;

    address public USDT = 0x3813e82e6f7098b9583FC0F33a962D02018B6803;
    BlockHeads public blockHeadCharacter;

    // Price
    uint256 public characterNFTPrice = 0.02 * 10 ** 6;
    uint256 public weaponNFTPrice = 0.01 * 10 ** 6;

    // Stats
    uint256 public totalCharactersMinted = 0;
    uint256 public totalWeaponsMinted = 0;

    event NewCharacterMinted(address indexed owner);
    event NewWeaponMinted(address indexed owner);
    event CharacterPriceChanged(uint256 newPrice);
    event WeaponPriceChanged(uint256 newPrice);
    event CollectedSales(address indexed collector, uint256 amount);

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
        address _accessControl,
        address _BlockHeadCharacter
    ) {
        accessControl = BlockHeadAccessControl(_accessControl);
        blockHeadCharacter = BlockHeads(_BlockHeadCharacter);
    }

    function getTotalCharactersMinted() public view returns (uint256) {
        return totalCharactersMinted;
    }

    function getTotalWeaponsMinted() public view returns (uint256) {
        return totalWeaponsMinted;
    }

    /**
     * @dev Mint a new character
     */
    function buyNewCharacter(uint256 qty) public returns (bool) {
        require(
            qty > 0, 
            "BlockHeads: Quantity must be greater than 0"
        );

        uint256 usdtBalance = IERC20(USDT).balanceOf(msg.sender);
        uint256 totalPrice = characterNFTPrice * qty;

        require(
            usdtBalance >= totalPrice,
            "BlockHeads: Not enough USDT balance"
        );

        // Transfer USDT to contract
        IERC20(USDT).transferFrom(msg.sender, address(this), totalPrice);

        // Mint NFT
        blockHeadCharacter.createBlockHeads(msg.sender, qty);
        totalCharactersMinted += qty;

        emit NewCharacterMinted(msg.sender);

        return true;
    }

    function buyNewWeapon(address to, uint256 qty) public returns (bool) {
        
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

    /**
     * @dev Set the price of a character
     */
    function setCharacterPrice(uint256 _price) public onlyAdmin {
        characterNFTPrice = _price;

        emit CharacterPriceChanged(_price);
    }

    /**
     * @dev Set the price of a weapon
     */
    function setWeaponPrice(uint256 _price) public onlyAdmin {
        weaponNFTPrice = _price;

        emit WeaponPriceChanged(_price);
    }

    /**
     * @dev Collect minting sales
     */
    function collectSales() public onlyAdmin {
        uint256 usdtBalance = IERC20(USDT).balanceOf(address(this));
        require(
            usdtBalance > 0,
            "BlockHeads: No USDT balance to collect"
        );

        // Approve USDT
        IERC20(USDT).approve(address(this), usdtBalance);
        // Transfer USDT to contract
        IERC20(USDT).transferFrom(address(this), msg.sender, usdtBalance);

        emit CollectedSales(msg.sender, usdtBalance);
    }
}