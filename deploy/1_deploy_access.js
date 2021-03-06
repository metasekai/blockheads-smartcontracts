async function main() {
  // We get the contract to deploy
  const BlockHeadAccessControl = await hre.ethers.getContractFactory('BlockHeadAccessControl');
  const blockHeadAccessControl = await BlockHeadAccessControl.deploy();

  await blockHeadAccessControl.deployed();

  console.log('BlockHeadAccessControl deployed to:', blockHeadAccessControl.address);
  console.log('Verifying Contract...');

  try {
    await hre.run('verify:verify', {
      address: blockHeadAccessControl.address,
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
