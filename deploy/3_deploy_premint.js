import config from '../config';

async function main() {
  // We get the contract to deploy
  const contractParams = [config.accessControlAddress, config.characterNFTAddress];
  const BlockHeadMinter = await hre.ethers.getContractFactory('BlockHeadMinter');
  const blockHeadMinter = await BlockHeadMinter.deploy(...contractParams);

  await blockHeadMinter.deployed();

  console.log('BlockHeadMinter deployed to:', blockHeadMinter.address);
  console.log('Verifying Contract...');

  try {
    await hre.run('verify:verify', {
      address: blockHeadMinter.address,
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
