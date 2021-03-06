const config = require('../config');

async function main() {
  // We get the contract to deploy
  const contractParams = [config.accessControlAddress];
  const BlockHeads = await hre.ethers.getContractFactory('BlockHeads');
  const blockHeads = await BlockHeads.deploy(...contractParams);

  await blockHeads.deployed();

  console.log('BlockHeads deployed to:', blockHeads.address);
  console.log('Verifying Contract...');

  try {
    await hre.run('verify:verify', {
      address: blockHeads.address,
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
