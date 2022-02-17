import config from '../config';
const {  utils } = require("ethers");

async function main() {
    const totalSupply = 100000000;
    const maxCap = totalSupply * 0.001;
   
    //convert from wei
    const contractParams = [utils.parseEther(maxCap.toString()), config.accessControlAddress];
    // We get the contract to deploy
    const BlockHeadToken = await hre.ethers.getContractFactory("BlockHeadToken");
    const blockHeadToken = await BlockHeadToken.deploy(...contractParams);
    
    //Set Contract
    await blockHeadToken.deployed();
  
    console.log("BlockHead Token deployed to:", blockHeadToken.address);

    console.log("Total Supply", blockHeadToken._getMaxHolding());
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  