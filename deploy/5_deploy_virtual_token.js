import config from '../config';

async function main() {
    //convert from wei
    const contractParams = [config.accessControlAddress];
    // We get the contract to deploy
    const VirtualBlockHeadToken = await hre.ethers.getContractFactory("VirtualBlockHeadToken");
    const virtualBlockHeadToken = await VirtualBlockHeadToken.deploy(
        ...contractParams
    );
    
    //Set Contract
    await virtualBlockHeadToken.deployed();
  
    console.log("Virtual BlockHead Token deployed to:", virtualBlockHeadToken.address);

    try {
        await hre.run('verify:verify', {
          address: virtualBlockHeadToken.address,
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
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  