const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('PreMinting', function () {
  let AccessControl;
  let CharacterNFT;
  let BlockHeadMinter;
  let accessControl;
  let blockHeads;
  let blockHeadMinter;
  let owner;
  let address1;

  before(async function () {
    AccessControl = await ethers.getContractFactory('BlockHeadAccessControl');
    CharacterNFT = await ethers.getContractFactory('BlockHeads');
    BlockHeadMinter = await ethers.getContractFactory('BlockHeadMinter');

    // deploy the contracts
    accessControl = await AccessControl.deploy();
    blockHeads = await CharacterNFT.deploy(accessControl.address);
    blockHeadMinter = await BlockHeadMinter.deploy(accessControl.address, blockHeads.address);

    [owner, address1] = await ethers.getSigners();
  });

  describe('Access Control', function () {
    it('Should be able to give minter role', async function () {
      const minterRole = await accessControl.MINTER_ROLE();
      const tx = await accessControl.grantRole(minterRole, blockHeadMinter.address);
      await tx.wait();

      const tx2 = await accessControl.grantRole(minterRole, owner.address);
      await tx2.wait();

      const hasMinterRole = await accessControl.hasMinterRole(blockHeadMinter.address);
      const ownerHasMinterRole = await accessControl.hasMinterRole(owner.address);

      expect(hasMinterRole).to.equal(true);
      expect(ownerHasMinterRole).to.equal(true);
    });
  });

  describe('Character NFT', function () {
    it('Should be able to mint an NFT', async function () {
      // Mint a new NFT
      const minted = await blockHeads.createBlockHeads(owner.address, 1);
      const receipt = await minted.wait();

      // Check balance of owner
      const balance = await blockHeads.balanceOf(owner.address);
      expect(balance.toNumber()).to.equal(1);
    });
  });

  //   describe('PreMinter', function () {
  //     it('Should be able to premint NFTs', async function () {
  //       // Buy a new
  //     });
  //   });
});
