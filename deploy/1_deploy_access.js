async function main() {
  // We get the contract to deploy
  const BlockHeadAccessControl = await hre.ethers.getContractFactory('BlockHeadAccessControl');
  const blockHeadAccessControl = await BlockHeadAccessControl.deploy();

  await blockHeadAccessControl.deployed();

  console.log('BlockHeadAccessControl deployed to:', blockHeadAccessControl.address);

  hre.run('verify:verify', {
    address: blockHeadAccessControl.address,
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
