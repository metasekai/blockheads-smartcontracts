// SPDX-License-Identifier: MIT
/**
 * @author Alleo Indong
 */

pragma solidity ^0.8.0;

import '../Access/BlockHeadAccessControl.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract BlockHeadsMarketplace is Pausable, ReentrancyGuard {
  using SafeMath for uint256;

  struct MarketItem {
    address seller; // owner of the item
    uint256 price; // listed price
    uint256 timestamp;
  }

  BlockHeadAccessControl public accessControl;

  // marketplace tax
  uint256 public salesTax = 40000000000000000; // 4% initially

  // Mapping of marketItems, nftAddress => tokenId => marketItem
  mapping(address => mapping(uint256 => MarketItem)) public marketItems;
  // amount of nfts for sale
  uint256 public itemListedCount = 0;

  // State variables for monitoring sales
  uint256 public totalSold; // sold qty
  uint256 public totalSales; // total sales

  // Token to use on the marketplace
  IERC20 public token;

  // Wallet of treasury where sales will go
  address public treasuryWallet;

  // Marketplace events
  event ItemListed(address nftAddress, address seller, uint256 tokenId, uint256 price);
  event ItemSold(address nftAddress, address seller, uint256 tokenId, address buyer, uint256 price);
  event ItemUnlisted(address nftAddress, address seller, uint256 tokenId);

  constructor(
    address _accesControl,
    address _token,
    address _treasuryWallet
  ) {
    accessControl = BlockHeadAccessControl(_accesControl);
    token = IERC20(_token);
    treasuryWallet = _treasuryWallet;
  }

  /**
   * @dev Allow only admin role to operate on certain functions
   */
  modifier onlyAdmin() {
    require(accessControl.hasAdminRole(msg.sender), 'BlockHead: Only admin can perform this action');
    _;
  }

  // Modifier to save gas and check if the given input
  // can be stored safely in memory
  modifier canBeStoredWith128Bits(uint256 _value) {
    require(_value < 340282366920938463463374607431768211455, 'BlockHead: Value is too large');
    _;
  }

  /**
   * @dev List an item for sale on the marketplace
   * @param _nftAddress address of the NFT contract to be listed
   * @param _tokenId tokenId of the nft
   * @param _price price of the item
   */
  function listItem(
    address _nftAddress,
    uint256 _tokenId,
    uint256 _price
  ) external whenNotPaused nonReentrant canBeStoredWith128Bits(_price) {
    address _seller = msg.sender;
    // Price should be greater than 0
    require(_price > 0, 'BlockHead: Price should be greater than 0');
    // Check if the tokenId is already listed
    require(marketItems[_nftAddress][_tokenId].seller == _seller, 'BlockHead: Item is already listed');
    // Check if msg.sender is the owner of the token
    require(_owns(_nftAddress, _seller, _tokenId), 'BlockHead: Only the owner can list an item');

    // Transfer the item to the marketplace contract - Escrow
    _escrow(_nftAddress, _seller, _tokenId); // The marketplace contract now holds the NFT

    MarketItem memory _item = MarketItem(_seller, uint128(_price), block.timestamp);
    // Add the _item to the marketItems mapping
    _addMarketItem(_nftAddress, _tokenId, _item);
  }

  /**
   * @dev Get the listed item information
   * @param _nftAddress address of the NFT contract
   * @param _tokenId tokenId of the nft
   *
   */
  function getItemInformation(address _nftAddress, uint256 _tokenId)
    external
    view
    returns (
      address seller,
      uint256 price,
      uint256 timestamp
    )
  {
    // validate if the tokenId is listed for sale
    require(marketItems[_nftAddress][_tokenId].price > 0, 'BlockHead: Item is not listed');
    MarketItem storage _item = marketItems[_nftAddress][_tokenId];

    return (_item.seller, _item.price, _item.timestamp);
  }

  /**
   * @dev Buy an item from the marketplace
   * @param _nftAddress address of the NFT contract
   * @param _tokenId tokenId of the nft
   */
  function unlistItem(address _nftAddress, uint256 _tokenId) external whenNotPaused nonReentrant {
    address _seller = msg.sender;
    // Check nft ownership
    require(_owns(_nftAddress, _seller, _tokenId), 'BlockHead: Only the owner can unlist an item');
    // Check if the tokenId is listed for sale
    require(marketItems[_nftAddress][_tokenId].price > 0, 'BlockHead: Item is not listed');

    MarketItem memory _item = marketItems[_nftAddress][_tokenId];

    // Remove the item from the marketItems mapping
    _removeMarketItem(_nftAddress, _tokenId);
    // Return the item to the seller
    _returnItem(_nftAddress, _seller, _tokenId);

    // Emmit the ItemUnlisted Event
    emit ItemUnlisted(_nftAddress, _item.seller, _tokenId);
  }

  function buyItem(address _nftAddress, uint256 _tokenId) external whenNotPaused nonReentrant {
    address _buyer = msg.sender;
    // Check if the tokenId is listed for sale
    require(marketItems[_nftAddress][_tokenId].price > 0, 'BlockHead: Item is not listed');
    // Check if the buyer is the seller
    require(marketItems[_nftAddress][_tokenId].seller != _buyer, 'BlockHead: You cannot buy your own item');
    MarketItem memory _item = marketItems[_nftAddress][_tokenId];

    // Check if the buyer has enough funds
    require(_getUserBalance(_buyer) > _item.price, 'BlockHead: Not enough funds');

    // Transfer the funds to the seller
    _chargeTheBuyerAndPayTheSeller(_buyer, _item.seller, _item.price);

    // Transfer the item to the buyer
    _transfer(_nftAddress, _buyer, _tokenId);

    // Update the total sales
    totalSales += _item.price;
    // Update the total sold
    totalSold += 1;

    // Remove the token from the marketplace
    _removeMarketItem(_nftAddress, _tokenId);

    // Emit the ItemSold Event
    emit ItemSold(_nftAddress, _item.seller, _tokenId, _buyer, _item.price);
  }

  /**
   * @dev Get the computed sales tax
   * @param _price price of the item
   */
  function getSalesTax(uint256 _price) public view returns (uint256) {
    // i.g 1 ether * 4% = 0.04 ether
    // 1000000000000000000 * 40000000000000000 = 40000000000000000
    // 10 ether * 4% = 0.4 ether
    return _price.mul(salesTax);
  }

  /** Admin functions */

  /**
   * @dev Pause the contract
   */
  function puase() external onlyAdmin {
    _pause();
  }

  /**
   * @dev Unpause the contract
   */
  function unpause() external onlyAdmin {
    _unpause();
  }

  /**
   * @dev Set the tax for every sales
   */
  function setSalesTax(uint256 _salesTax) external onlyAdmin {
    require(_salesTax > 0, 'BlockHead: Sales tax must be greater than 0');
    salesTax = _salesTax;
  }

  /** Private functions */

  /**
   * @dev Gets the NFT object from an address, validate that address is
   * implements IERC21 interface
   */
  function _getNftContract(address _nftAddress) internal pure returns (IERC721) {
    return IERC721(_nftAddress);
  }

  /**
   * @dev Validates ownership of an NFT token
   * @param _nftAddress NFT contract address
   * @param _claimant address of the claimant
   * @param _tokenId NFT token id
   */
  function _owns(
    address _nftAddress,
    address _claimant,
    uint256 _tokenId
  ) internal view returns (bool) {
    IERC721 nft = _getNftContract(_nftAddress);
    return nft.ownerOf(_tokenId) == _claimant;
  }

  /**
   * @dev Escrow the NFT token, let the marketplace hold the NFT
   * @param _nftAddress NFT contract address
   * @param _seller address of the seller
   * @param _tokenId NFT token id
   */
  function _escrow(
    address _nftAddress,
    address _seller,
    uint256 _tokenId
  ) internal {
    IERC721 _nftContract = _getNftContract(_nftAddress);

    // Transfer the item to the marketplace safely
    _nftContract.safeTransferFrom(_seller, address(this), _tokenId);
  }

  function _returnItem(
    address _nftAddress,
    address _seller,
    uint256 _tokenId
  ) internal {
    IERC721 _nftContract = _getNftContract(_nftAddress);

    // Transfer the item to the seller safely
    _nftContract.safeTransferFrom(address(this), _seller, _tokenId);
  }

  /**
   * @dev Add an item to the marketItems mapping
   * @param _nftAddress NFT contract address
   * @param _tokenId NFT token id
   */
  function _addMarketItem(
    address _nftAddress,
    uint256 _tokenId,
    MarketItem memory _marketItem
  ) internal {
    // Add the item to the marketItems mapping
    marketItems[_nftAddress][_tokenId] = _marketItem;
    itemListedCount++;

    // Emmit the ItemListed Event
    emit ItemListed(_nftAddress, _marketItem.seller, _tokenId, _marketItem.price);
  }

  /**
   * @dev Remove an item from the marketItems mapping
   * @param _nftAddress NFT contract address
   * @param _tokenId NFT token id
   */
  function _removeMarketItem(address _nftAddress, uint256 _tokenId) internal {
    // Remove the item from the marketItems mapping
    delete marketItems[_nftAddress][_tokenId];
    itemListedCount--;
  }

  /**
   * @dev Get the user token balance
   */
  function _getUserBalance(address _user) internal view returns (uint256) {
    return token.balanceOf(_user);
  }

  /**
   * @dev Transfer the NFT token to the buyer
   */
  function _transfer(
    address _nftAddress,
    address _to,
    uint256 _tokenId
  ) internal {
    IERC721 _nftContract = _getNftContract(_nftAddress);

    // Transfer the item to the seller safely
    _nftContract.safeTransferFrom(address(this), _to, _tokenId);
  }

  /**
   * @dev Pay the seller - salesTax
   * @param _seller address of the seller
   * @param _price price of the item
   */
  function _chargeTheBuyerAndPayTheSeller(
    address _buyer,
    address _seller,
    uint256 _price
  ) internal {
    uint256 saleTax = getSalesTax(_price);
    // Transfer the funds to the seller - saleTax
    token.transferFrom(_buyer, _seller, _price.sub(saleTax));

    // Transfer the tax fees to the treasury
    token.transferFrom(_buyer, treasuryWallet, salesTax);
  }
}
