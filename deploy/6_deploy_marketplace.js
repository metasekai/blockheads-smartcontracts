const config = require('../config');

async function main() {
  // We get the contract to deploy
  const contractParams = [config.accessControlAddress, config.daiAddress, config.treasuryAddress];
  const BlockHeadsMarketplace = await hre.ethers.getContractFactory('BlockHeadsMarketplace');
  const blockHeadsMarketplace = await BlockHeadsMarketplace.deploy(...contractParams);

  await blockHeadsMarketplace.deployed();

  console.log('BlockHeadsMarketplace deployed to:', blockHeadsMarketplace.address);
  console.log('Verifying Contract...');

  try {
    await hre.run('verify:verify', {
      address: blockHeadsMarketplace.address,
      constructorArguments: contractParams,
    });
  } catch (e) {
    console.error('Cant verify contract');
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
